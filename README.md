# Pok-QA-Academy
A fun and interactive way to learn and practice writing Unit Tests and UI Tests using XCTest and XCUITest.

## Getting Started (Fork + Run)

This project is intended to be forked so you can practice writing **XCTest** and **XCUITest**.

### First Run Setup (Required)
When you fork this repo, you’ll need to select your own signing team to run the app locally.

1. Fork this repository and clone it to your machine
2. Open `PokéQAAcademy.xcodeproj` in Xcode
3. Select the **PokéQAAcademy** target
4. Go to **Signing & Capabilities**
5. Set **Team** to your Apple ID / Development Team
6. Press **Run**

> Note: The project uses a generic bundle identifier (`com.example...`) so it’s safe for forks and won’t conflict with your own apps.

## Recommended Git Hook (Optional)

This repo includes a pre-commit hook that prevents committing an Apple
Development Team ID into the project.

After cloning, run:

git config core.hooksPath .githooks

---

## Privacy / Commit Email
You may notice commits use a GitHub `users.noreply.github.com` email address.

This repo is designed to be forked and shared publicly, so commit history uses a private GitHub noreply email to avoid exposing personal email addresses. If you fork this repo and want the same behavior, you can enable **Keep my email addresses private** in GitHub Settings and configure Git to use your noreply email.