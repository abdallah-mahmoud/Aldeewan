import type { Person, Transaction } from '../types';
import { PersonRole, TransactionType } from '../types';

/**
 * Calculates the final balance for a given person based on a list of transactions.
 * @param person The person (customer or supplier) for whom to calculate the balance.
 * @param transactions A list of all transactions in the system.
 * @returns The final numerical balance.
 */
export function calculatePersonBalance(person: Person | undefined, transactions: Transaction[]): number {
    if (!person) return 0;

    return transactions
        .filter(t => t.personId === person.id)
        .reduce((balance, t) => {
            if (person.role === PersonRole.CUSTOMER) {
                if (t.type === TransactionType.SALE_ON_CREDIT) return balance + t.amount;
                if (t.type === TransactionType.PAYMENT_RECEIVED) return balance - t.amount;
            } else { // Supplier
                if (t.type === TransactionType.PURCHASE_ON_CREDIT) return balance + t.amount;
                if (t.type === TransactionType.PAYMENT_MADE) return balance - t.amount;
            }
            return balance;
        }, 0);
}
