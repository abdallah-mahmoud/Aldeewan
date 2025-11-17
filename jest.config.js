/** @type {import('ts-jest').JestConfigWithTsJest} */
module.exports = {
  preset: 'ts-jest',
  testEnvironment: 'jsdom',
  setupFilesAfterEnv: ['<rootDir>/jest.setup.js'],
  moduleNameMapper: {
    // If you have CSS modules or other file types to mock in tests
    // '\\.(css|less|scss|sass)$': 'identity-obj-proxy',
  },
};
