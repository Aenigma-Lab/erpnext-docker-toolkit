🚀 ERPNext Docker Installer & Uninstaller Script


One-click install/uninstall ERPNext using Docker – Simple, Fast, and Hassle-Free
🛠️ Features

    🐳 Docker-Based – Clean and isolated ERPNext setup using Docker containers.

    ⚙️ Install Script – Spin up ERPNext in minutes.

    🔁 Uninstall Script – Remove all containers, volumes, and configs with a single command.

    🧑‍💻 User-Friendly UI – Simple terminal prompts and visual cues.

    🌐 Cross-platform – Works on Linux, macOS, and WSL (Windows Subsystem for Linux).

    🔐 Optional SSL Setup – Easily integrate with Let's Encrypt for HTTPS.

    📦 Modular Setup – Customize your environment (e.g., MariaDB, Redis, NGINX).

📸 UI Preview

    Add a screenshot or terminal snippet here to showcase the install/uninstall prompt.

Welcome to ERPNext Docker Installer 🚀
--------------------------------------
[1] Install ERPNext
[2] Uninstall ERPNext
[3] Exit

📁 Project Structure

  📦 erpnext-docker-installer
 ┣ 📜 install.sh
 ┣ 📜 uninstall.sh
 ┣ 📄 README.md
 ┗ 📂 docker-compose
     ┣ 📜 docker-compose.yml
     ┗ 📜 .env

📦 Requirements

    Docker

    Docker Compose

    Bash

⚡ Quick Start

  git clone https://github.com/yourusername/erpnext-docker-installer.git
  cd erpnext-docker-installer
  chmod +x install.sh uninstall.sh
  ./install.sh

To remove ERPNext completely:
    ./uninstall.sh

🤝 Contributing

    Pull requests are welcome! Please open issues first to discuss major changes.
    Make sure to update tests as appropriate.
    📄 License

MIT License

