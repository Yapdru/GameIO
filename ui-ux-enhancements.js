// Comprehensive UI/UX Enhancements System
// Advanced styling, interactions, and visual polish

class UIEnhancer {
  constructor() {
    this.modals = new Map();
    this.tooltips = new Map();
    this.notifications = [];
    this.styles = new Map();
    this.themes = new Map();
    this.currentTheme = 'default';
  }

  // Create enhanced button
  createButton(config = {}) {
    const {
      text = 'Button',
      onClick = () => {},
      style = 'primary',
      size = 'medium',
      icon = '',
      disabled = false,
      tooltip = ''
    } = config;

    const button = document.createElement('button');
    button.className = `btn btn-${style} btn-${size}`;
    button.textContent = text;
    button.onclick = onClick;
    button.disabled = disabled;

    if (icon) {
      button.innerHTML = `${icon} ${text}`;
    }

    if (tooltip) {
      this.addTooltip(button, tooltip);
    }

    return button;
  }

  // Create enhanced input field
  createInput(config = {}) {
    const {
      type = 'text',
      placeholder = '',
      value = '',
      label = '',
      required = false,
      validation = null,
      onChange = () => {}
    } = config;

    const wrapper = document.createElement('div');
    wrapper.className = 'input-wrapper';

    if (label) {
      const labelEl = document.createElement('label');
      labelEl.textContent = label;
      labelEl.className = required ? 'required' : '';
      wrapper.appendChild(labelEl);
    }

    const input = document.createElement('input');
    input.type = type;
    input.placeholder = placeholder;
    input.value = value;
    input.required = required;

    input.addEventListener('change', (e) => {
      if (validation && !validation(e.target.value)) {
        input.classList.add('invalid');
        this.showNotification('Invalid input', 'error');
      } else {
        input.classList.remove('invalid');
        onChange(e.target.value);
      }
    });

    wrapper.appendChild(input);
    return wrapper;
  }

  // Create progress bar
  createProgressBar(config = {}) {
    const {
      value = 0,
      max = 100,
      label = '',
      showLabel = true,
      animated = true,
      color = '#0f8fe8'
    } = config;

    const container = document.createElement('div');
    container.className = `progress-container ${animated ? 'animated' : ''}`;

    if (label && showLabel) {
      const labelEl = document.createElement('label');
      labelEl.textContent = label;
      container.appendChild(labelEl);
    }

    const barContainer = document.createElement('div');
    barContainer.className = 'progress-bar-container';

    const bar = document.createElement('div');
    bar.className = 'progress-bar';
    bar.style.width = `${(value / max) * 100}%`;
    bar.style.backgroundColor = color;

    barContainer.appendChild(bar);
    container.appendChild(barContainer);

    if (showLabel) {
      const percentage = document.createElement('span');
      percentage.className = 'progress-percentage';
      percentage.textContent = `${Math.round((value / max) * 100)}%`;
      container.appendChild(percentage);
    }

    container.update = (newValue) => {
      bar.style.width = `${(newValue / max) * 100}%`;
      if (showLabel) {
        percentage.textContent = `${Math.round((newValue / max) * 100)}%`;
      }
    };

    return container;
  }

  // Create card component
  createCard(config = {}) {
    const {
      title = '',
      content = '',
      footer = '',
      action = null,
      image = '',
      hoverable = true
    } = config;

    const card = document.createElement('div');
    card.className = `card ${hoverable ? 'hoverable' : ''}`;

    if (image) {
      const img = document.createElement('img');
      img.src = image;
      img.className = 'card-image';
      card.appendChild(img);
    }

    if (title) {
      const titleEl = document.createElement('h3');
      titleEl.className = 'card-title';
      titleEl.textContent = title;
      card.appendChild(titleEl);
    }

    const contentEl = document.createElement('div');
    contentEl.className = 'card-content';
    contentEl.innerHTML = content;
    card.appendChild(contentEl);

    if (action) {
      const actionEl = this.createButton({
        text: action.text,
        onClick: action.onClick,
        style: 'primary',
        size: 'small'
      });
      actionEl.className = 'card-action';
      card.appendChild(actionEl);
    }

    if (footer) {
      const footerEl = document.createElement('div');
      footerEl.className = 'card-footer';
      footerEl.textContent = footer;
      card.appendChild(footerEl);
    }

    return card;
  }

  // Create modal dialog
  createModal(config = {}) {
    const {
      title = 'Modal',
      content = '',
      actions = [],
      closeable = true,
      width = '500px'
    } = config;

    const modalId = 'modal-' + Math.random().toString(36).slice(2);

    const overlay = document.createElement('div');
    overlay.className = 'modal-overlay';
    overlay.id = modalId + '-overlay';

    const modal = document.createElement('div');
    modal.className = 'modal';
    modal.style.width = width;
    modal.id = modalId;

    // Header
    const header = document.createElement('div');
    header.className = 'modal-header';

    const titleEl = document.createElement('h2');
    titleEl.textContent = title;
    header.appendChild(titleEl);

    if (closeable) {
      const closeBtn = document.createElement('button');
      closeBtn.className = 'modal-close';
      closeBtn.textContent = '✕';
      closeBtn.onclick = () => this.closeModal(modalId);
      header.appendChild(closeBtn);
    }

    modal.appendChild(header);

    // Content
    const contentEl = document.createElement('div');
    contentEl.className = 'modal-content';
    contentEl.innerHTML = content;
    modal.appendChild(contentEl);

    // Footer with actions
    if (actions.length > 0) {
      const footer = document.createElement('div');
      footer.className = 'modal-footer';

      actions.forEach(action => {
        const btn = this.createButton({
          text: action.text,
          onClick: () => {
            action.onClick?.();
            this.closeModal(modalId);
          },
          style: action.style || 'primary'
        });
        footer.appendChild(btn);
      });

      modal.appendChild(footer);
    }

    overlay.appendChild(modal);

    // Close on overlay click
    overlay.onclick = (e) => {
      if (e.target === overlay && closeable) {
        this.closeModal(modalId);
      }
    };

    document.body.appendChild(overlay);
    this.modals.set(modalId, { overlay, modal });

    // Animate in
    setTimeout(() => {
      overlay.classList.add('active');
      modal.classList.add('active');
    }, 10);

    return modalId;
  }

  // Close modal
  closeModal(modalId) {
    const modal = this.modals.get(modalId);
    if (modal) {
      modal.overlay.classList.remove('active');
      modal.modal.classList.remove('active');

      setTimeout(() => {
        modal.overlay.remove();
        this.modals.delete(modalId);
      }, 300);
    }
  }

  // Add tooltip
  addTooltip(element, content, position = 'top') {
    element.addEventListener('mouseenter', () => {
      const tooltip = document.createElement('div');
      tooltip.className = `tooltip tooltip-${position}`;
      tooltip.textContent = content;
      document.body.appendChild(tooltip);

      const rect = element.getBoundingClientRect();
      if (position === 'top') {
        tooltip.style.left = rect.left + rect.width / 2 - tooltip.offsetWidth / 2 + 'px';
        tooltip.style.top = rect.top - tooltip.offsetHeight - 10 + 'px';
      } else if (position === 'bottom') {
        tooltip.style.left = rect.left + rect.width / 2 - tooltip.offsetWidth / 2 + 'px';
        tooltip.style.top = rect.bottom + 10 + 'px';
      }

      element._tooltip = tooltip;
    });

    element.addEventListener('mouseleave', () => {
      if (element._tooltip) {
        element._tooltip.remove();
        element._tooltip = null;
      }
    });
  }

  // Show notification
  showNotification(message, type = 'info', duration = 3000) {
    const notification = document.createElement('div');
    notification.className = `notification notification-${type}`;
    notification.textContent = message;

    document.body.appendChild(notification);

    setTimeout(() => {
      notification.classList.add('show');
    }, 10);

    setTimeout(() => {
      notification.classList.remove('show');
      setTimeout(() => notification.remove(), 300);
    }, duration);
  }

  // Create loading spinner
  createLoadingSpinner(size = 'medium') {
    const spinner = document.createElement('div');
    spinner.className = `spinner spinner-${size}`;

    const style = document.createElement('style');
    style.textContent = `
      @keyframes spin {
        to { transform: rotate(360deg); }
      }
      .spinner {
        border: 3px solid rgba(15, 143, 232, 0.1);
        border-radius: 50%;
        border-top-color: #0f8fe8;
        animation: spin 0.8s linear infinite;
      }
      .spinner-small { width: 20px; height: 20px; }
      .spinner-medium { width: 40px; height: 40px; }
      .spinner-large { width: 60px; height: 60px; }
    `;

    if (!document.head.querySelector(`style[data-spinner="true"]`)) {
      style.dataset.spinner = 'true';
      document.head.appendChild(style);
    }

    return spinner;
  }

  // Create theme
  createTheme(name, config = {}) {
    const {
      primaryColor = '#0f8fe8',
      secondaryColor = '#ffd84d',
      backgroundColor = '#dffaff',
      textColor = '#12304a',
      borderColor = '#82dcff',
      shadowColor = 'rgba(0, 0, 0, 0.1)'
    } = config;

    const colors = {
      primary: primaryColor,
      secondary: secondaryColor,
      background: backgroundColor,
      text: textColor,
      border: borderColor,
      shadow: shadowColor
    };

    this.themes.set(name, colors);

    // Generate CSS variables
    const cssVariables = Object.entries(colors)
      .map(([key, value]) => `--color-${key}: ${value};`)
      .join('\n');

    const style = document.createElement('style');
    style.textContent = `:root { ${cssVariables} }`;
    document.head.appendChild(style);

    return colors;
  }

  // Apply theme
  applyTheme(name) {
    const theme = this.themes.get(name);
    if (!theme) {
      console.warn(`Theme "${name}" not found`);
      return;
    }

    this.currentTheme = name;

    // Update CSS variables
    Object.entries(theme).forEach(([key, value]) => {
      document.documentElement.style.setProperty(`--color-${key}`, value);
    });
  }

  // Create responsive grid
  createGrid(config = {}) {
    const {
      columns = 3,
      gap = '16px',
      items = []
    } = config;

    const grid = document.createElement('div');
    grid.className = 'grid';
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = `repeat(auto-fit, minmax(${100 / columns}%, 1fr))`;
    grid.style.gap = gap;

    items.forEach(item => {
      grid.appendChild(item);
    });

    return grid;
  }

  // Create tab interface
  createTabs(config = {}) {
    const {
      tabs = [],
      activeTab = 0,
      onChange = () => {}
    } = config;

    const container = document.createElement('div');
    container.className = 'tabs-container';

    const tabButtons = document.createElement('div');
    tabButtons.className = 'tab-buttons';

    const tabContents = document.createElement('div');
    tabContents.className = 'tab-contents';

    tabs.forEach((tab, index) => {
      const btn = document.createElement('button');
      btn.className = `tab-button ${index === activeTab ? 'active' : ''}`;
      btn.textContent = tab.label;
      btn.onclick = () => {
        document.querySelectorAll('.tab-button').forEach(b => b.classList.remove('active'));
        document.querySelectorAll('.tab-content').forEach(c => c.classList.remove('active'));
        btn.classList.add('active');
        document.getElementById(`tab-content-${index}`).classList.add('active');
        onChange(index);
      };
      tabButtons.appendChild(btn);

      const content = document.createElement('div');
      content.id = `tab-content-${index}`;
      content.className = `tab-content ${index === activeTab ? 'active' : ''}`;
      content.innerHTML = tab.content;
      tabContents.appendChild(content);
    });

    container.appendChild(tabButtons);
    container.appendChild(tabContents);

    return container;
  }

  // Add glassmorphism effect
  addGlassmorphism(element) {
    element.style.background = 'rgba(255, 255, 255, 0.1)';
    element.style.backdropFilter = 'blur(10px)';
    element.style.border = '1px solid rgba(255, 255, 255, 0.2)';
    element.style.borderRadius = '10px';
  }

  // Add neumorphism effect
  addNeumorphism(element) {
    element.style.background = '#e8f0f8';
    element.style.borderRadius = '20px';
    element.style.boxShadow = `
      8px 8px 16px #a3b1c1,
      -8px -8px 16px #ffffff
    `;
  }

  // Add gradient text
  addGradientText(element, color1 = '#0f8fe8', color2 = '#ffd84d') {
    element.style.background = `linear-gradient(135deg, ${color1}, ${color2})`;
    element.style.webkitBackgroundClip = 'text';
    element.style.webkitTextFillColor = 'transparent';
    element.style.backgroundClip = 'text';
  }
}

// Global UI enhancer instance
window.UIEnhancer = new UIEnhancer();

// Create default theme
window.UIEnhancer.createTheme('default', {
  primaryColor: '#0f8fe8',
  secondaryColor: '#ffd84d',
  backgroundColor: '#dffaff',
  textColor: '#12304a',
  borderColor: '#82dcff'
});

export { UIEnhancer };
