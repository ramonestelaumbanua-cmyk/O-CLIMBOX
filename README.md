# O-CLIMBOX

Sistem instrumentasi dan pemantauan kualitas air laut berbasis IoT (*Internet of Things*). Repositori ini memuat arsitektur perangkat keras dan perangkat lunak untuk akuisisi data sensor lingkungan kelautan secara *real-time*.

## Struktur Direktori

Proyek ini dibagi menjadi dua bagian utama:

*   **📁 Hardware**: Berisi skematik *wiring*, konfigurasi, file desain cetak 3D (`.stl`), dan kode mikrokontroler (menggunakan Arduino Mega & ESP32). Sistem ini mengintegrasikan pembacaan sensor multi-parameter seperti pH, *Total Dissolved Solids* (TDS), *Dissolved Oxygen* (DO), *Electrical Conductivity* (EC), Suhu, dan sensor Ultrasonik.
*   **📁 Software**: Berisi arsitektur *flow* Node-RED, konfigurasi komunikasi (MQTT, Modbus RTU/RS485 via *gateway* industri), serta pengaturan untuk visualisasi *dashboard* dan penyimpanan data.

## Deskripsi Singkat
O-CLIMBOX dirancang untuk mempermudah pengambilan data parameter oseanografi secara otomatis. Data dari berbagai sensor dibaca oleh mikrokontroler, kemudian dikirimkan melalui protokol komunikasi yang stabil untuk divisualisasikan dan dianalisis lebih lanjut.

## Lisensi
Proyek ini dilisensikan di bawah [Creative Commons Attribution 4.0 International License](https://creativecommons.org/licenses/by/4.0/). Anda diizinkan untuk membagikan dan mengadaptasi materi ini, asalkan memberikan atribusi yang sesuai kepada pembuat asli.
