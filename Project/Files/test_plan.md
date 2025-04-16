# Database Test Plan: MultimediaContentDB

By MAzen IF THIS IS TO STUPID/CRINGE FEEL FREE TO DELETE I JUST WANNA SHOW MY FULL PLAN

## 1. Overview
This document outlines the test strategy for validating the schema, constraints, and data integrity of the MultimediaContentDB. It includes test cases for each table, relationship, and key business logic.

---

## 2. Data Loading
- **Source**: Project/Datasets/Data.csv
- **Goal**: Transform and load data into normalized tables (Content, Director, Actor, Country, Genre, etc.).
- **Note**: finna use da  scripts or ETL tools to split flat data into relational inserts.

---

## 3. Test Cases

### 3.1 Table Insertions
- [ ] Insert rows into all base tables (User, Content, Genre, Country, etc.)
- [ ] Insert rows into all junction tables (e.g., Content_Actor, Content_Director)

### 3.2 Constraints
- [ ] Attempt to insert duplicate primary keys (should fail)
- [ ] Attempt to insert duplicate unique fields (e.g., User.email)
- [ ] Attempt to insert invalid foreign keys (should fail)

### 3.3 Relationships
- [ ] Validate many-to-many links (e.g., Content_Actor, Content_Genre)
- [ ] Validate one-to-many links (e.g., User → Review)
- [ ] Validate ISA logic (e.g., only valid User can be Actor/Director)

### 3.4 Edge Cases
- [ ] Insert content with missing optional fields
- [ ] Insert watch history with non-existent user/content (should fail)
- [ ] Insert playlist with duplicate content (should fail if not allowed)

---

## 4. Validation Queries
- List all content with their genres, directors, and actors
- List all users and their playlists, watchlists, and watch history
- Check for orphaned rows (e.g., Content with no Genre)
- Check referential integrity (no broken FKs)

---

## 5. Checklist
- [ ] All tables populated
- [ ] All constraints tested
- [ ] All relationships validated
- [ ] Edge cases covered
- [ ] Data integrity confirmed

---

## 6. Notes
- Document any issues found and how they were resolved.
- Update this file as you add more tests or discover edge cases.

---

**Prepared by:** Database Analyst/Tester Mazen Zwin
**Date:** 2025-04-16
