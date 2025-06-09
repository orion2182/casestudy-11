# Gunakan base image Python yang ringan
FROM python:3.9-slim

# Tetapkan direktori kerja di dalam container
WORKDIR /app

# Salin file requirements terlebih dahulu untuk memanfaatkan cache Docker
COPY requirements.txt .

# Instal semua dependensi Python
RUN pip install --no-cache-dir -r requirements.txt

# Salin sisa kode aplikasi ke dalam direktori kerja
COPY . .

# Expose port yang digunakan oleh aplikasi Flask
EXPOSE 5000

# Perintah untuk menjalankan aplikasi saat container dimulai
CMD ["python", "app.py"]
