from flask import Flask

# Inisialisasi aplikasi Flask
app = Flask(__name__)

@app.route('/')
def hello():
    """Menampilkan pesan sapaan."""
    return "Hello, World! Aplikasi Python ini di-deploy oleh Jenkins."

if __name__ == '__main__':
    # Menjalankan aplikasi di host 0.0.0.0 agar bisa diakses dari luar container
    app.run(host='0.0.0.0', port=5000)
