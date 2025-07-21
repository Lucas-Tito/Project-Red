# TODO: Board Sharing Feature Implementation

This checklist outlines the steps needed to implement the board sharing feature with secure token-based access and real-time updates.

---

## 1. Create Model and Migration

- [ x ] Generate migration for `BoardSharedLink`
- [ ] Define the schema with token, permission level, expiration date, and foreign keys
- [ ] Add unique index on `token`
- [ ] Create `BoardSharedLink` model
  - [ ] Add associations to `Board` and `User`
  - [ ] Define `permission` enum (`viewer`, `editor`)
  - [ ] Add validations for `token` and `permission`
  - [ ] Add callbacks to generate `token` and set `expires_at`
  - [ ] Define helper methods like `expired?` and `url(request)`

---

## 2. Define Routes

- [ ] Add nested resource `board_shared_links` under `boards`
  - Actions: `create`, `index`

---

## 3. Create Controller

- [ ] Create `BoardSharedLinksController`
  - [ ] `index` action to list links (authorized via Pundit)
  - [ ] `create` action to create new shared link (authorized via Pundit)
  - [ ] Permit `permission` param only
  - [ ] Render appropriate partial or JSON error

---

## 4. Implement Authorization with Pundit

- [ ] Add `share?`, `show?`, and `update?` methods to `BoardPolicy`
  - Handle access via ownership or valid token
- [ ] Modify `BoardPolicy` constructor to accept a token
- [ ] Add `Scope` class (even if returning `scope.all` for now)

---

## 5. Modify ApplicationController

- [ ] Add `before_action :handle_shared_token`
- [ ] Implement `handle_shared_token` to save token to session
- [ ] Override `pundit_user` to pass `UserContext` with tokens
- [ ] Define `BoardPolicy::UserContext` struct
- [ ] Override `authorize` to use token from session
- [ ] Update `authenticate_user` to allow token-based access

---

## 6. Set Up ActionCable for Real-Time Collaboration

- [ ] Generate `BoardChannel`
- [ ] Stream for board on subscription
- [ ] In `TasksController` and `ListsController`, broadcast changes:
  - [ ] Task creation
  - [ ] Task update
  - [ ] Task deletion
- [ ] Implement `render_task` to render task partial for broadcast

---

## 7. Add Stimulus Controller for Real-Time Updates

- [ ] Create `board_subscription_controller.js`
  - [ ] Connect to `BoardChannel`
  - [ ] Handle `task_created`, `task_updated`, `task_destroyed`
- [ ] Insert HTML updates dynamically into DOM
- [ ] Add Stimulus controller to board HTML (`index.html.erb`)

---

## Optional Enhancements

- [ ] Support more broadcast types (list created, list updated, etc.)
- [ ] Add UI to manage and revoke shared links
- [ ] Display expiration date and permissions in UI


