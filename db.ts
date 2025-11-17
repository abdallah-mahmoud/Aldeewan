// FIX: Switched from a default to a named import for the Dexie class.
// This resolves an issue where subclassing Dexie did not correctly inherit
// its methods like `.version()` and `.transaction()` at compile time.
import { Dexie } from 'dexie';
import type { Table } from 'dexie';
import type { Person, Transaction } from './types';

export class AlDeewanDB extends Dexie {
  persons!: Table<Person, string>;
  transactions!: Table<Transaction, string>;

  // Declare old tables to be used during the version upgrade.
  ledgerEntries!: Table<any, string>;
  cashEntries!: Table<any, string>;

  constructor() {
    super('AlDeewanDB');
    
    // Version 1 had separate tables for ledger and cash entries.
    this.version(1).stores({
      persons: 'id, name',
      ledgerEntries: 'id, personId, date',
      cashEntries: 'id, date, type, category',
    });

    // Version 2 consolidates entries into a single 'transactions' table.
    this.version(2).stores({
      persons: 'id, name',
      // The old tables 'ledgerEntries' and 'cashEntries' are removed implicitly.
      transactions: 'id, personId, date, type, category',
    }).upgrade(tx => {
        // A real migration would move data from old tables to the new one.
        // For this development setup, we just clear the old tables before they are dropped.
        return Promise.all([
            tx.table('ledgerEntries').clear(),
            tx.table('cashEntries').clear()
        ]);
    });
  }

  async exportDB(): Promise<Blob> {
    const dataToExport = await this.transaction('r', this.persons, this.transactions, async () => {
      const persons = await this.persons.toArray();
      const transactions = await this.transactions.toArray();
      return { persons, transactions };
    });
    return new Blob([JSON.stringify(dataToExport, null, 2)], { type: 'application/json' });
  }

  async importDB(jsonContent: string): Promise<void> {
    await this.transaction('rw', this.persons, this.transactions, async () => {
      const data = JSON.parse(jsonContent);

      // Basic validation
      if (!data.persons || !data.transactions || !Array.isArray(data.persons) || !Array.isArray(data.transactions)) {
        throw new Error("Invalid backup file format.");
      }

      await this.persons.clear();
      await this.transactions.clear();

      await this.persons.bulkAdd(data.persons);
      await this.transactions.bulkAdd(data.transactions);
    });
  }
}

export const db = new AlDeewanDB();