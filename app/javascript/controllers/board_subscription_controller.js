import { Controller } from "@hotwired/stimulus"
import { createConsumer } from "@rails/actioncable"

export default class extends Controller {
  static values = { boardId: Number }

  connect() {
    this.subscription = createConsumer().subscriptions.create(
      { channel: "BoardChannel", board_id: this.boardIdValue },
      {
        received: data => {
          this.handleRealTimeUpdate(data);
        }
      }
    )
  }

  disconnect() {
    this.subscription.unsubscribe();
  }

  handleRealTimeUpdate(data) {
    switch(data.action) {
      // Task actions
      case 'task_created':
        this.handleTaskCreated(data);
        break;
      case 'task_updated':
        this.handleTaskUpdated(data);
        break;
      case 'task_deleted':
        this.handleTaskDeleted(data);
        break;
      case 'task_completed':
        this.handleTaskCompleted(data);
        break;
      case 'task_snoozed':
        this.handleTaskSnoozed(data);
        break;
      
      // List actions
      case 'list_created':
        this.handleListCreated(data);
        break;
      case 'list_updated':
        this.handleListUpdated(data);
        break;
      case 'list_deleted':
        this.handleListDeleted(data);
        break;
      case 'list_moved':
        this.handleListMoved(data);
        break;
      
      // Board actions
      case 'board_updated':
        this.handleBoardUpdated(data);
        break;
      case 'board_deleted':
        this.handleBoardDeleted(data);
        break;
      
      // Shared link actions
      case 'shared_link_created':
        this.handleSharedLinkCreated(data);
        break;
    }
  }

  handleTaskCreated(data) {
    if (data.html) {
      const listTasksContainer = document.getElementById(`list_${data.list_id}_tasks_container`);
      if (listTasksContainer) {
        listTasksContainer.outerHTML = data.html;
      }
    }
  }

  handleTaskUpdated(data) {
    // For task updates, we might need to refresh the entire list to ensure consistency
    if (data.list_id) {
      const listTasksContainer = document.getElementById(`list_${data.list_id}_tasks_container`);
      if (listTasksContainer) {
        // Trigger a refresh of the task list
        this.refreshTasksList(data.list_id);
      }
    }
  }

  handleTaskDeleted(data) {
    if (data.html) {
      const listTasksContainer = document.getElementById(`list_${data.list_id}_tasks_container`);
      if (listTasksContainer) {
        listTasksContainer.outerHTML = data.html;
      }
    }
  }

  handleTaskCompleted(data) {
    if (data.html) {
      const listTasksContainer = document.getElementById(`list_${data.list_id}_tasks_container`);
      if (listTasksContainer) {
        listTasksContainer.outerHTML = data.html;
      }
    }
  }

  handleTaskSnoozed(data) {
    if (data.html) {
      const listTasksContainer = document.getElementById(`list_${data.list_id}_tasks_container`);
      if (listTasksContainer) {
        listTasksContainer.outerHTML = data.html;
      }
    }
  }

  // List management methods
  handleListCreated(data) {
    if (data.html) {
      const addNewListPlaceholder = document.getElementById('add_new_list_placeholder');
      if (addNewListPlaceholder) {
        addNewListPlaceholder.insertAdjacentHTML('beforebegin', data.html);
      }
      
      // Remove empty board message if it exists
      const emptyBoardMessage = document.getElementById('empty_board_message');
      if (emptyBoardMessage) {
        emptyBoardMessage.remove();
      }
    }
  }

  handleListUpdated(data) {
    if (data.html && data.list) {
      const listElement = document.getElementById(`list_${data.list.id}`);
      if (listElement) {
        listElement.outerHTML = data.html;
      }
    }
  }

  handleListDeleted(data) {
    const listElement = document.getElementById(`list_${data.list_id}`);
    if (listElement) {
      listElement.remove();
    }
  }

  handleListMoved(data) {
    // For list reordering, we might need to refresh the entire board layout
    // This is more complex as it involves DOM manipulation for positioning
    this.refreshBoardLayout();
  }

  // Board management methods
  handleBoardUpdated(data) {
    if (data.board) {
      // Update board title or other board-specific elements
      const boardTitleElement = document.querySelector('[data-board-title]');
      if (boardTitleElement && data.board.name) {
        boardTitleElement.textContent = data.board.name;
      }
      
      // Show notification
      this.showNotification(`Board "${data.board.name}" foi atualizado por outro usuário.`);
    }
  }

  handleBoardDeleted(data) {
    // Redirect to home or show message that board was deleted
    this.showNotification('Este board foi excluído por outro usuário. Redirecionando...', 'error');
    setTimeout(() => {
      window.location.href = '/';
    }, 2000);
  }

  // Shared link management
  handleSharedLinkCreated(data) {
    this.showNotification('Um novo link de compartilhamento foi criado para este board.');
  }

  // Helper methods
  refreshTasksList(listId) {
    // This could trigger a fetch to get updated task list content
    // For now, we'll just show a notification
    console.log(`Refreshing tasks for list ${listId}`);
  }

  refreshBoardLayout() {
    // This could trigger a full board refresh
    // For now, we'll reload the page as a fallback
    window.location.reload();
  }

  showNotification(message, type = 'info') {
    // Create a simple notification element
    const notification = document.createElement('div');
    notification.className = `notification notification-${type} fixed top-4 right-4 bg-blue-500 text-white px-4 py-2 rounded shadow-lg z-50`;
    notification.textContent = message;
    
    document.body.appendChild(notification);
    
    // Remove notification after 5 seconds
    setTimeout(() => {
      if (notification.parentNode) {
        notification.parentNode.removeChild(notification);
      }
    }, 5000);
  }
}