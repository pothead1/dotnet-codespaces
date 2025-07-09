#!/bin/bash

# =======================
# SYSTEM & ENVIRONMENT SETUP
# =======================

# Detect OS and set package manager
if [ -f /etc/debian_version ]; then
  PM="apt-get"
  SUDO="sudo"

elif [ -f /etc/redhat-release ]; then
  PM="yum"
  SUDO="sudo"
else
  echo "Unsupported OS."
  exit 1
fi

$SUDO $PM update && $SUDO $PM upgrade -y

# Install core tools and package managers
$SUDO $PM install -y git curl wget zsh python3 python3-pip nodejs npm openjdk-11-jre make gcc unzip jq \
  build-essential tmux htop tree zip tar net-tools dnsutils lsof software-properties-common apt-transport-https ca-certificates gnupg lsb-release

# Install additional languages and package managers
$SUDO $PM install -y ruby ruby-dev golang-go php php-cli composer rustc cargo perl perl-modules default-jre default-jdk

# Editors and shells
$SUDO $PM install -y vim nano emacs neovim fish

# VSCode and extensions
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
$SUDO install -o root -g root -m 644 packages.microsoft.gpg /usr/share/keyrings/
$SUDO sh -c 'echo "deb [arch=amd64 signed-by=/usr/share/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
$SUDO $PM install -y apt-transport-https
$SUDO $PM update
$SUDO $PM install -y code
code --install-extension ms-python.python
code --install-extension ms-vscode.vscode-typescript-next
code --install-extension ms-azuretools.vscode-docker
code --install-extension esbenp.prettier-vscode
code --install-extension dbaeumer.vscode-eslint

# Python and Node.js frameworks/libraries
pip3 install --user django flask requests fastapi numpy pandas matplotlib scipy jupyterlab virtualenv \
  tensorflow torch transformers scikit-learn beautifulsoup4 scrapy selenium nlpaug textattack
npm install -g react express typescript vue angular create-react-app nodemon eslint prettier yarn playwright cypress

# Ruby, Go, PHP, Rust, Perl libraries
gem install rails sinatra bundler
go install github.com/gin-gonic/gin@latest
composer global require laravel/installer
cargo install ripgrep exa bat fd-find
cpan install Mojolicious

# Docker, databases, cloud tools
$SUDO $PM install -y docker.io docker-compose postgresql postgresql-contrib mysql-server redis-server mongodb-org sqlite3
pip3 install --user awscli google-cloud-sdk azure-cli
$SUDO $PM install -y kubectl helm terraform ansible

# Virtualization/containerization
$SUDO $PM install -y vagrant virtualbox qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils

# Additional utilities and security tools
$SUDO $PM install -y openssh-server fail2ban ufw nmap lynis clamav trivy

# Monitoring, visualization, reporting
$SUDO $PM install -y prometheus grafana

# GUI automation, RPA, and desktop automation
pip3 install --user pyautogui pywinauto

# Web scraping, testing, and browser automation
pip3 install --user playwright

# Clone dotfiles and scripts
git clone https://github.com/youruser/dotfiles.git ~/dotfiles
cp ~/dotfiles/.bashrc ~/.bashrc
cp ~/dotfiles/.zshrc ~/.zshrc
cp ~/dotfiles/scripts/* ~/bin/
chmod +x ~/bin/*

# Set environment variables
echo 'export PATH="$PATH:$HOME/bin:$HOME/.cargo/bin:$HOME/.composer/vendor/bin:$HOME/go/bin"' >> ~/.bashrc
echo 'export JAVA_HOME="/usr/lib/jvm/java-11-openjdk-amd64"' >> ~/.bashrc
echo 'export NODE_ENV=development' >> ~/.bashrc
echo 'export EDITOR=vim' >> ~/.bashrc
echo 'export GOPATH=$HOME/go' >> ~/.bashrc
echo 'export PYTHONPATH=$HOME/.local/lib/python3.*/site-packages' >> ~/.bashrc
echo 'export LANG=en_US.UTF-8' >> ~/.bashrc
echo 'export LC_ALL=en_US.UTF-8' >> ~/.bashrc
source ~/.bashrc

chmod -R 755 ~/bin
$SUDO chown -R $USER:$USER ~/bin

$SUDO usermod -aG docker $USER
$SUDO usermod -aG vboxusers $USER
$SUDO usermod -aG libvirt $USER
$SUDO usermod -aG adm $USER

$SUDO systemctl enable --now docker
$SUDO systemctl enable --now postgresql
$SUDO systemctl enable --now mysql
$SUDO systemctl enable --now redis-server
$SUDO systemctl enable --now mongod

$SUDO ufw allow OpenSSH
$SUDO ufw allow 5432/tcp
$SUDO ufw allow 3306/tcp
$SUDO ufw allow 6379/tcp
$SUDO ufw allow 27017/tcp
$SUDO ufw --force enable

(crontab -l 2>/dev/null; echo "0 3 * * * $SUDO $PM update && $SUDO $PM upgrade -y && $SUDO freshclam && $SUDO lynis audit system") | crontab -

echo "✅ All tools, SDKs, frameworks, libraries, databases, environment variables, and security settings are installed and configured with full access."

# =======================
# PROJECT STRUCTURE & INIT
# =======================

echo "📁 Creating universal project structure..."

PROJECTS_DIR=~/projects
PROJECT_NAME=my_cool_project
PROJECT_PATH="$PROJECTS_DIR/$PROJECT_NAME"
mkdir -p "$PROJECT_PATH"
cd "$PROJECT_PATH"
mkdir -p src tests docs scripts data/raw data/processed configs logs .vscode notebooks .github/workflows .devcontainer

# Python project structure
mkdir -p src/python
touch src/python/__init__.py
echo "# Main Python script" > src/python/main.py
echo "pytest" > requirements.txt

# Node.js project structure
mkdir -p src/node
echo '{}' > src/node/package.json
echo "// Main Node.js script" > src/node/index.js

# Web project structure
mkdir -p src/web/static src/web/templates
echo "<!DOCTYPE html><html><head><title>My App</title></head><body></body></html>" > src/web/templates/index.html
echo "body { font-family: Arial; }" > src/web/static/styles.css
echo "console.log('Hello, world!');" > src/web/static/app.js

# Data science/project structure
mkdir -p data/raw data/processed notebooks
touch notebooks/README.md

# Docker and CI/CD
echo -e "FROM python:3.11\nWORKDIR /app\nCOPY . .\nRUN pip install -r requirements.txt\nCMD [\"python3\", \"src/python/main.py\"]" > Dockerfile
echo -e "stages:\n  - test\n  - build\n  - deploy" > .gitlab-ci.yml

# VSCode workspace settings example
cat <<EOF > .vscode/settings.json
{
  "python.pythonPath": "\$HOME/.local/bin/python3",
  "editor.tabSize": 4,
  "files.exclude": {
    "**/__pycache__": true
  }
}
EOF

# Git setup
git init
echo -e "logs/\n__pycache__/\n*.pyc\nnode_modules/\ndata/\n.env\n" > .gitignore

chmod -R 755 "$PROJECT_PATH"
$SUDO chown -R $USER:$USER "$PROJECT_PATH"

cd "$PROJECT_PATH"

# 1. Initialize Version Control and Project Configs
if [ ! -d ".git" ]; then
  git init
  echo "✅ Git initialized."
fi
# Optionally add remote (customize URL)
# git remote add origin https://github.com/youruser/yourrepo.git

# Generate README, LICENSE, CONTRIBUTING
echo "# $PROJECT_NAME" > README.md
echo "MIT License" > LICENSE
echo "## How to contribute" > CONTRIBUTING.md

# Create sample .env and config files
echo "DEBUG=True
SECRET_KEY=changeme
DATABASE_URL=sqlite:///data/dev.db
" > .env
echo "{ \"setting\": \"value\" }" > configs/config.json

# 2. Set Up Virtual Environments and Dependency Managers

# Python: venv and requirements
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip setuptools wheel
pip install -r requirements.txt || pip freeze > requirements.txt

# Node.js: npm/yarn install
cd src/node
npm install || yarn install
cd "$PROJECT_PATH"

# Other languages (examples)
# Ruby: bundle install
# Go: go mod init && go mod tidy

# 3. Automate Build and Test Processes

# Build script
echo -e "#!/bin/bash\npython3 -m compileall src/python" > scripts/build.sh
chmod +x scripts/build.sh

# Test script
echo -e "#!/bin/bash\npytest tests" > scripts/test.sh
chmod +x scripts/test.sh

# Node test script (in package.json)
jq '.scripts.test="echo \"Error: no test specified\" && exit 1"' src/node/package.json > tmp.$$.json && mv tmp.$$.json src/node/package.json

# CI/CD config (GitHub Actions)
mkdir -p .github/workflows
cat <<EOF > .github/workflows/ci.yml
name: CI
on: [push]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Set up Python
        uses: actions/setup-python@v2
        with:
          python-version: '3.x'
      - name: Install dependencies
        run: |
          python -m pip install --upgrade pip
          pip install -r requirements.txt
      - name: Run tests
        run: |
          pytest tests
EOF

# 4. Ensure Isolation and Replicability

# Dockerfile already created above
# Add docker-compose.yml
cat <<EOF > docker-compose.yml
version: '3'
services:
  app:
    build: .
    ports:
      - "8000:8000"
    volumes:
      - .:/app
    env_file:
      - .env
EOF

# Devcontainer config for VSCode
mkdir -p .devcontainer
cat <<EOF > .devcontainer/devcontainer.json
{
  "name": "$PROJECT_NAME",
  "dockerFile": "../Dockerfile",
  "settings": {},
  "extensions": [
    "ms-python.python",
    "ms-vscode.vscode-typescript-next"
  ]
}
EOF

# 5. Data Management and Mock Data

# Mock data script
echo -e "#!/bin/bash\necho \"id,name\n1,Alice\n2,Bob\" > data/raw/mock_users.csv" > scripts/generate_mock_data.sh
chmod +x scripts/generate_mock_data.sh
./scripts/generate_mock_data.sh

# Data masking example
echo -e "#!/bin/bash\nsed -i 's/Alice/AnonUser1/g' data/raw/mock_users.csv" > scripts/mask_data.sh
chmod +x scripts/mask_data.sh

# 6. Documentation and Onboarding

# Add onboarding doc
echo "## Onboarding\n1. Clone repo\n2. Run setup script\n3. Start coding!" > docs/ONBOARDING.md

# Update README with setup instructions
cat <<EOF >> README.md

## Setup

\`\`\`bash
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
cd src/node
npm install
cd ../..
\`\`\`
EOF

# 7. Telemetry and Monitoring (Optional)

# Example: Add logging config
echo "LOG_LEVEL=INFO" >> .env
echo -e "# Logging config\nlog_level = 'INFO'" > configs/logging.conf

# Example: Add placeholder for monitoring script
echo -e "#!/bin/bash\necho 'Monitoring not yet implemented'" > scripts/monitor.sh
chmod +x scripts/monitor.sh

echo "✅ Project initialization, automation, isolation, data management, documentation, and onboarding completed."

# === Chatbot Training Data Generation ===

echo "🗃️  Generating sample chatbot training data..."

# 1. Simple Q&A pairs (CSV)
cat <<EOF > data/raw/chatbot_qa.csv
question,answer
"Hello","Hi there!"
"What is your name?","I'm a chatbot."
"How can you help me?","I can answer your questions."
EOF

# 2. Multi-turn conversations (JSON)
cat <<EOF > data/raw/chatbot_conversations.json
[
  {
    "conversation_id": 1,
    "dialogue": [
      {"user": "Hi", "bot": "Hello! How can I assist you today?"},
      {"user": "Tell me a joke", "bot": "Why did the chicken cross the road? To get to the other side!"}
    ]
  },
  {
    "conversation_id": 2,
    "dialogue": [
      {"user": "What's the weather?", "bot": "It's sunny and 75°F."},
      {"user": "Thanks!", "bot": "You're welcome!"}
    ]
  }
]
EOF

# 3. Intent classification (CSV)
cat <<EOF > data/raw/chatbot_intents.csv
utterance,intent
"Book a flight","book_flight"
"Cancel my reservation","cancel_reservation"
"What's the weather?","get_weather"
EOF

# 4. Entity recognition (JSON)
cat <<EOF > data/raw/chatbot_entities.json
[
  {"text": "Book a flight from Paris to Berlin", "entities": [{"entity": "location", "value": "Paris"}, {"entity": "location", "value": "Berlin"}]},
  {"text": "Reserve a table for two at 7pm", "entities": [{"entity": "party_size", "value": "two"}, {"entity": "time", "value": "7pm"}]}
]
EOF

# 5. FAQ pairs (YAML)
cat <<EOF > data/raw/chatbot_faq.yaml
- question: "How do I reset my password?"
  answer: "Click on 'Forgot password' at the login screen."
- question: "Can I change my email address?"
  answer: "Yes, go to account settings and update your email."
EOF

# 6. Custom formatted data (TXT)
cat <<EOF > data/raw/chatbot_custom.txt
[USER] Hello
[BOT] Hi! How can I help you?

[USER] What can you do?
[BOT] I can chat and answer your questions.
EOF

echo "✅ Multiple types of chatbot training data generated in data/raw/"

# === Advanced NLP Dataset Templates and Data Augmentation Integration ===

echo "🧠 Generating advanced NLP datasets and augmentation scripts..."

# 1. Sentiment Analysis (CSV)
cat <<EOF > data/raw/sentiment_dataset.csv
text,label
"I love this product!","positive"
"This is the worst experience ever.","negative"
"It's okay, not great.","neutral"
EOF

# 2. Topic Classification (CSV)
cat <<EOF > data/raw/topic_classification.csv
text,topic
"Stocks are up today on Wall Street.","finance"
"The new movie was fantastic!","entertainment"
"New species discovered in the Amazon.","science"
EOF

# 3. Named Entity Recognition (CoNLL format)
cat <<EOF > data/raw/ner_conll.txt
John B-PER
lives O
in O
New B-LOC
York I-LOC
. O

Apple B-ORG
released O
the O
iPhone B-PROD
. O
EOF

# 4. Summarization (CSV)
cat <<EOF > data/raw/summarization.csv
text,summary
"Natural language processing enables computers to understand human language. It is used in chatbots, translation, and more.","NLP helps computers understand language."
EOF

# 5. Machine Translation (TSV)
cat <<EOF > data/raw/translation.tsv
en	fr
"How are you?"	"Comment ça va ?"
"I am fine."	"Je vais bien."
EOF

# 6. Dialogue/Conversational (JSONL)
cat <<EOF > data/raw/dialogue.jsonl
{"context": ["Hello!", "Hi, how can I help you?"], "response": "What's the weather like today?"}
{"context": ["Can you play music?", "Sure, what would you like to hear?"], "response": "Play some jazz."}
EOF

# 7. Question Answering (SQuAD-style JSON)
cat <<EOF > data/raw/qa_squad.json
{
  "data": [
    {
      "title": "NLP",
      "paragraphs": [
        {
          "context": "Natural language processing (NLP) is a field of AI.",
          "qas": [
            {
              "id": "1",
              "question": "What is NLP?",
              "answers": [{"text": "a field of AI", "answer_start": 34}]
            }
          ]
        }
      ]
    }
  ]
}
EOF

# 8. Paraphrase Identification (CSV)
cat <<EOF > data/raw/paraphrase.csv
text1,text2,is_paraphrase
"How are you doing?","How do you do?",1
"What's your name?","Where do you live?",0
EOF

# 9. Hate Speech/Offensive Detection (CSV)
cat <<EOF > data/raw/hate_speech.csv
text,label
"I hate you!","hate"
"Have a nice day!","neutral"
EOF

# 10. Spam Detection (CSV)
cat <<EOF > data/raw/spam.csv
text,label
"Congratulations, you've won a prize!","spam"
"Let's meet for lunch tomorrow.","ham"
EOF

# 11. Reading Comprehension (JSON)
cat <<EOF > data/raw/reading_comprehension.json
[
  {
    "passage": "The sun rises in the east.",
    "question": "Where does the sun rise?",
    "answer": "in the east"
  }
]
EOF

# 12. Data Augmentation Scripts (Python)
cat <<EOF > scripts/augment_nlp_data.py
import nlpaug.augmenter.word as naw
import textattack.augmentation as ta_aug
import pandas as pd

# Example: Synonym augmentation with nlpaug
def augment_sentiment(input_csv, output_csv):
    df = pd.read_csv(input_csv)
    aug = naw.SynonymAug(aug_src='wordnet')
    df['augmented'] = df['text'].apply(lambda x: aug.augment(x))
    df.to_csv(output_csv, index=False)

# Example: TextAttack paraphrasing
def textattack_paraphrase(input_csv, output_csv):
    aug = ta_aug.ParaphraseAugmenter()
    df = pd.read_csv(input_csv)
    df['paraphrased'] = df['text'].apply(lambda x: aug.augment(x)[0])
    df.to_csv(output_csv, index=False)

if __name__ == "__main__":
    augment_sentiment('data/raw/sentiment_dataset.csv', 'data/processed/sentiment_augmented.csv')
    textattack_paraphrase('data/raw/sentiment_dataset.csv', 'data/processed/sentiment_paraphrased.csv')
EOF

chmod +x scripts/augment_nlp_data.py

if [ -d "venv" ]; then
  source venv/bin/activate
  pip install nlpaug textattack pandas
fi

echo "✅ Advanced NLP datasets and augmentation scripts created in data/raw/ and scripts/"

# === ALL ADVANCED AUTOMATION MODULES ===

# 1. Robotic Process Automation (RPA) Integration
cat <<EOF > scripts/rpa_example.py
import pyautogui
pyautogui.alert('RPA test: This is an automated popup!')
EOF

# 2. Machine Learning & AI Integration
cat <<EOF > scripts/train_model.py
import tensorflow as tf
from tensorflow import keras
import numpy as np
model = keras.Sequential([keras.layers.Dense(1, input_shape=(1,))])
model.compile(optimizer='sgd', loss='mean_squared_error')
x = np.array([1,2,3,4], dtype=float)
y = np.array([2,4,6,8], dtype=float)
model.fit(x, y, epochs=10)
model.save('data/processed/simple_model.h5')
EOF

# 3. Automated Software Testing
cat <<EOF > scripts/test_web.py
from selenium import webdriver
driver = webdriver.Firefox()
driver.get('https://example.com')
assert "Example Domain" in driver.title
driver.quit()
EOF

# 4. Cloud Automation
cat <<EOF > scripts/main.tf
provider "aws" {
  region = "us-east-1"
}
resource "aws_s3_bucket" "bucket" {
  bucket = "my-automation-bucket"
  acl    = "private"
}
EOF

# 5. Web Scraping and Data Collection
cat <<EOF > scripts/scrape_example.py
import scrapy
class QuotesSpider(scrapy.Spider):
    name = "quotes"
    start_urls = ['http://quotes.toscrape.com/']
    def parse(self, response):
        for quote in response.css('div.quote'):
            yield {'text': quote.css('span.text::text').get()}
EOF

# 6. API Integration and Automation
cat <<EOF > scripts/api_integration.py
import requests
r = requests.get('https://api.github.com')
print(r.json())
EOF

# 7. Advanced Project Scripts for Data Integrity
cat <<EOF > scripts/data_integrity.py
import pandas as pd
df = pd.read_csv('data/raw/sentiment_dataset.csv')
assert not df.isnull().values.any(), "Missing values detected!"
EOF

# 8. Monitoring, Logging, and Alerting
cat <<EOF > scripts/monitoring_stub.py
# Placeholder for Prometheus/Grafana/ELK integration
print("Monitoring and logging not yet implemented.")
EOF

# 9. Security Automation
cat <<EOF > scripts/security_scan.sh
#!/bin/bash
trivy fs .
EOF
chmod +x scripts/security_scan.sh

# 10. Data Visualization and Reporting
cat <<EOF > scripts/plot_report.py
import pandas as pd
import matplotlib.pyplot as plt
df = pd.read_csv('data/raw/sentiment_dataset.csv')
df['label'].value_counts().plot(kind='bar')
plt.savefig('data/processed/sentiment_report.png')
EOF

# 11. Code Quality and Linting Automation
cat <<EOF > scripts/lint_code.sh
#!/bin/bash
black src/python
eslint src/node
EOF
chmod +x scripts/lint_code.sh

# 12. Automated Documentation Generation
cat <<EOF > scripts/gen_docs.sh
#!/bin/bash
sphinx-quickstart docs/sphinx
jsdoc src/node -d docs/js
EOF
chmod +x scripts/gen_docs.sh

# 13. User/Permission Management
cat <<EOF > scripts/user_mgmt.sh
#!/bin/bash
sudo adduser newdev
sudo usermod -aG docker newdev
EOF
chmod +x scripts/user_mgmt.sh

# 14. Application Builder/GUI Automation
cat <<EOF > scripts/gui_builder.py
import tkinter as tk
root = tk.Tk()
root.title("Automation GUI")
tk.Label(root, text="Welcome to the Automation GUI").pack()
root.mainloop()
EOF

# 15. Continuous Monitoring and Self-Healing
cat <<EOF > scripts/self_heal.sh
#!/bin/bash
if ! pgrep -x "docker" > /dev/null; then
  sudo systemctl restart docker
fi
EOF
chmod +x scripts/self_heal.sh

echo "All advanced automation modules have been generated in the scripts/ directory."
echo "You can now run or extend these scripts for RPA, ML, cloud, scraping, monitoring, security, reporting, linting, docs, user management, GUI, and self-healing automation."
echo "✅ Full-stack, production-grade automation environment is ready."


