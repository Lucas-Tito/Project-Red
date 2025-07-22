# TODO: Board Sharing Feature Implementation

This checklist outlines the steps needed to implement the board sharing feature with secure token-based access and real-time updates.

---

## 1. Create Model and Migration

- [ x ] Generate migration for `BoardSharedLink`
- [ x ] Define the schema with token, permission level, expiration date, and foreign keys
- [ x ] Add unique index on `token`
- [ x ] Create `BoardSharedLink` model
  - [ x ] Add associations to `Board` and `User`
  - [ x ] Define `permission` enum (`viewer`, `editor`)
  - [ x ] Add validations for `token` and `permission`
  - [ x ] Add callbacks to generate `token` and set `expires_at`
  - [ x ] Define helper methods like `expired?` and `url(request)`

---

## 2. Define Routes

- [ x ] Add nested resource `board_shared_links` under `boards`
  - Actions: `create`, `index`

---

## 3. Create Controller

- [ x ] Create `BoardSharedLinksController`
  - [ x ] `index` action to list links (authorized via Pundit)
  - [ x ] `create` action to create new shared link (authorized via Pundit)
  - [ x ] Permit `permission` param only
  - [ x ] Render appropriate partial or JSON error

---

## 4. Implement Authorization with Pundit

- [ x ] Add `share?`, `show?`, and `update?` methods to `BoardPolicy`
  - Handle access via ownership or valid token
- [ x ] Modify `BoardPolicy` constructor to accept a token
- [ x ] Add `Scope` class (even if returning `scope.all` for now)

---

## 5. Modify ApplicationController

- [ x ] Add `before_action :handle_shared_token`
- [ x ] Implement `handle_shared_token` to save token to session
- [ x ] Override `pundit_user` to pass `UserContext` with tokens
- [ x ] Define `BoardPolicy::UserContext` struct
- [ x ] Override `authorize` to use token from session
- [ x ] Update `authenticate_user` to allow token-based access

---

## 6. Set Up ActionCable for Real-Time Collaboration

- [ x ] Generate `BoardChannel`
- [ x ] Stream for board on subscription
- [ x ] In `TasksController` and `ListsController`, broadcast changes:
  - [ x ] Task creation
  - [ x ] Task update
  - [ x ] Task deletion
- [ x ] Implement `render_task` to render task partial for broadcast

---

## 7. Add Stimulus Controller for Real-Time Updates

- [ x ] Create `board_subscription_controller.js`
  - [ x ] Connect to `BoardChannel`
  - [ x ] Handle `task_created`, `task_updated`, `task_destroyed`
- [ x ] Insert HTML updates dynamically into DOM
- [ x ] Add Stimulus controller to board HTML (`index.html.erb`)

---

## Optional Enhancements

- [ ] Support more broadcast types (list created, list updated, etc.)
- [ ] Add UI to manage and revoke shared links
- [ ] Display expiration date and permissions in UI


