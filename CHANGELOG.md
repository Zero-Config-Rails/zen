## [Unreleased]

## [0.2.4] - 2024-10-21

- Add "--skip-server" to bin/setup command so command to run rails server is skipped

## [0.2.3] - 2024-09-23

- Update global rails gem version to ensure `rails new` always installs latest stable Rails version
- Show boring_generator installation command before rails new
- Fix the issue of list of commands before `rails new` showing array for CI setup commands instead of regular list

## [0.2.2] - 2024-06-25

- Use custom branch for forked Boring Generators repo instead of main so it is easier to merge changes as required from boring generators later

## [0.2.1] - 2024-06-19

- Use boring generators from Zero Config Rails forked repo instead of the actual repo for better stability

## [0.2.0] - 2024-06-04

- Authenticate users with API token
- Show subscription inactive message if user is on Free plan or has cancelled their subscription
- Install and use Boring Generators from main branch instead of the latest released version of the gem

## [0.1.0] - 2024-05-04

- Initial release
