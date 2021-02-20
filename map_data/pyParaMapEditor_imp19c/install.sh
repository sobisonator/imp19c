echo "Installing Python environment"
python3 -m venv venv
pip install --upgrade pip
pip install --upgrade setuptools
pip install -r requirements.txt