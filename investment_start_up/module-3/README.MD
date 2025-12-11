# Database Module - Startup Reports

This module defines the database for managing startups, users, and model-generated reports. It was built to keep data organized, secure, and easy to analyze.

## What it does
- Private schema: stores sensitive info.
  - Models with metadata and performance metrics.
  - Users with email, password, and date of birth.
- Public schema: stores general app data.
  - Startups with basic info, funding, employees, revenue, and tags.
  - Reports linked to startups and models, including report URLs.
  - Users linked to reports.

## Why it exists
- Keeps sensitive data separate from public data.
- Structures data so reports and analysis are straightforward.
- Provides a clear foundation for any app or tool that needs to generate, view, or track startup reports.
