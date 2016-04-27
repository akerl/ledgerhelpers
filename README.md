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

### taxcalc

Uses a yaml file explaining taxes and pointing at Ledger account names to project tax burden and compare against withholdings. My YAML file:

```
taxable:
- Income:Salary:palantir
- Income:Bonus:palantir
deductions:
- name: Expenses:Commute:metro
- name: Assets:401K:Trad:palantir
  from:
  - federal_income
  - va_income
- name: Standard Federal Deduction
  amount: 6300
  from: federal_income
- name: Standard VA Deduction
  amount: 3000
  from: va_income
- name: Personal Federal Deduction
  amount: 4050
  from: federal_income
- name: Personal VA Deduction
  amount: 930
  from: va_income
brackets:
  federal_income:
  - rate: .10
    starts: 0
  - rate: .15
    starts: 9276
  - rate: .25
    starts: 37651
  - rate: .28
    starts: 91151
  - rate: .33
    starts: 190151
  - rate: .35
    starts: 413351
  - rate: .396
    starts: 415051
  va_income:
  - rate: .02
    starts: 0
  - rate: .03
    starts: 3001
  - rate: .05
    starts: 5001
  - rate: .0575
    starts: 17001
  medicare:
  - rate: .0145
    starts: 0
  social_security:
  - rate: .062
    starts: 0
```

## License

All scripts except those noted internally are released under the MIT License. See the bundled LICENSE file for details

