import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal", "permission", "linksList"]
  static values = { boardId: String }

  open() {
    this.modalTarget.classList.remove("hidden")
  }

  close() {
    this.modalTarget.classList.add("hidden")
  }

  async createLink(event) {
    event.preventDefault();
    const url = `/boards/${this.boardIdValue}/shared_links`;
    const permission = this.permissionTarget.value;
    const csrfToken = document.querySelector("[name='csrf-token']").content;
    const response = await fetch(url, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': csrfToken,
        'Accept': 'text/html'
      },
      body: JSON.stringify({ board_shared_link: { permission: permission } })
    });
    if (response.ok) {
      const newLinkHtml = await response.text();
      this.linksListTarget.insertAdjacentHTML('afterbegin', newLinkHtml);
    } else {
      console.error("Failed to create link");
    }
  }

  async revokeLink(event) {
    event.preventDefault();
    const linkId = event.params.id;
    const url = `/boards/${this.boardIdValue}/shared_links/${linkId}`

    const response = await fetch(url, {
      method: 'DELETE',
      headers: {
        'X-CSRF-Token': document.querySelector("[name='csrf-token']").content,
        'Accept': 'application/json'
      }
    })

    if (response.ok) {
      const elementToRemove = document.getElementById(`board_shared_link_${linkId}`)
      if (elementToRemove) {
        elementToRemove.remove()
      }
    } else {
      console.error("Failed to revoke link")
    }
  }

  copy(event) {
    const url = event.params.url;
    navigator.clipboard.writeText(url);
  }
}