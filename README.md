ledgerhelpers
============

These are some helper scripts I wrote for my usage of [ledger](http://www.ledger-cli.org).

### ldgproject

Uses [ballista](https://github.com/akerl/ballista) to generate ledger journals for the future using a simple YAML format:

```
- name: Pay Check
  when:
  - 15
  - 30
  actions:
    Expenses:Taxes:federal_income: $10.00
    Expenses:Taxes:va_income: $10.00
    Assets:Checking:simple: $100.00
    Assets:401K:Trad:palantir: $80.00
    Income:Salary:palantir: $-200.00
- name: A bill
  when: 2
  actions:
    Assets:Savings:ally: $20.00
    Assets:Checking:simple: null # If you leave something null, its amount is blank in the ledger (useful to avoid repetition for simple stuff)
```

## License

All scripts except those noted internally are released under the MIT License. See the bundled LICENSE file for details

