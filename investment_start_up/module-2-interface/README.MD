# Demo Interface - Flutter Form

A simple Flutter app to practice building forms. This is a practice model, so it’s straightforward, functional, and ready to tweak or extend later.

## What it does
- Lets you enter basic startup info:
  - ID, Name, Founded Year
  - Country, Region, Industry
  - Funding Round, Amount, Date
  - Lead Investor, Co-Investors
  - Employee Count, Estimated Revenue & Valuation
  - Tags / Keywords
- Validates that no fields are left empty.
- Number fields use the numeric keyboard.
- Press **Send** → shows a `SnackBar` with the startup name and prints all data to console.

## How it works
- `main()` runs `MyApp()`, which sets theme and opens `MyHomePage`.
- `MyHomePage` is stateful for form interaction.
- Each field has its own `TextEditingController`.
- `_buildTextField()` helper creates fields easily with validation and optional numeric keyboard.
- `_submitForm()` validates, collects data into a map, shows `SnackBar`, and prints data. Can be extended to send data to a database.

## Notes
- Scrollable form so it works with lots of fields.
- Good starting point for experimenting with Flutter forms and basic UI.
