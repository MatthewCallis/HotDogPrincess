# Change Log

## 0.3.1 (2014-11-13)

Fixes:

  - Simplify and speed up schema parsing.

## 0.3.0 (2014-10-30)

Features:

  - Return the error from Parature as an exception rather than RestClient errors.

Fixes:

  - Hashes strip `nil` values.
  - Typos in README.

## 0.2.2 (2014-08-22)

Fixes:

  - DO alter key names on schema.

## 0.2.1 (2014-08-22)

Fixes:

  - Don't alter key names on schema.

## 0.2.0 (2014-08-22)

Features:

  - Status, Schema and View return a Hash by default.

## 0.1.3 (2014-08-22)

Fixes:

  - Workaround bug in Status with `_output_=json`.

## 0.1.2 (2014-08-22)

Fixes:

  - Fix Status calls.

## 0.1.1 (2014-08-21)

Features:

  - First release
  - Support for Customers
  - Support for SLAs
  - Support for Tickets
  - Support Schema, Status and View on any object type.
  - Return Schema, Status and View as JSON.
