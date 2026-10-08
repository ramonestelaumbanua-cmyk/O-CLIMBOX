-- phpMyAdmin SQL Dump
-- version 5.1.1deb5ubuntu1
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Waktu pembuatan: 07 Okt 2026 pada 11.53
-- Versi server: 8.0.46-0ubuntu0.22.04.4
-- Versi PHP: 8.1.2-1ubuntu2.26

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `sensor_db`
--

-- --------------------------------------------------------

--
-- Struktur dari tabel `audit_log`
--

CREATE TABLE `audit_log` (
  `id` int NOT NULL,
  `user_id` int DEFAULT NULL,
  `username` varchar(50) DEFAULT NULL,
  `aksi` varchar(50) DEFAULT NULL,
  `detail` text,
  `stasiun_id` varchar(50) DEFAULT NULL,
  `waktu` datetime DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `jadwal_pompa`
--

CREATE TABLE `jadwal_pompa` (
  `pompa` varchar(50) NOT NULL,
  `jam_mulai` varchar(10) DEFAULT NULL,
  `durasi_detik` int DEFAULT NULL,
  `interval_detik` int DEFAULT NULL,
  `stasiun_id` varchar(50) NOT NULL DEFAULT 'Stasiun 01'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `readings`
--

CREATE TABLE `readings` (
  `id` int NOT NULL,
  `timestamp` datetime DEFAULT NULL,
  `do_saturation` float DEFAULT NULL,
  `do_mgl` float DEFAULT NULL,
  `do_temperature` float DEFAULT NULL,
  `ph` float DEFAULT NULL,
  `ph_temperature` float DEFAULT NULL,
  `orp` float DEFAULT NULL,
  `ec` float DEFAULT NULL,
  `salinity` float DEFAULT NULL,
  `tds` float DEFAULT NULL,
  `tds_temperature` float DEFAULT NULL,
  `latitude` float DEFAULT NULL,
  `longitude` float DEFAULT NULL,
  `stasiun_id` varchar(50) DEFAULT 'Stasiun 01'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `readings_lama`
--

CREATE TABLE `readings_lama` (
  `id` int NOT NULL,
  `timestamp` datetime DEFAULT NULL,
  `do_saturation` float DEFAULT NULL,
  `do_mgl` float DEFAULT NULL,
  `do_temperature` float DEFAULT NULL,
  `ph` float DEFAULT NULL,
  `ph_temperature` float DEFAULT NULL,
  `orp` float DEFAULT NULL,
  `ec` float DEFAULT NULL,
  `salinity` float DEFAULT NULL,
  `tds` float DEFAULT NULL,
  `tds_temperature` float DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `stations`
--

CREATE TABLE `stations` (
  `id` int NOT NULL,
  `nama` varchar(50) NOT NULL,
  `device` varchar(50) DEFAULT NULL,
  `topic_sub` varchar(100) NOT NULL,
  `topic_cmd` varchar(100) NOT NULL,
  `slave_id` int DEFAULT '100',
  `lat` double DEFAULT NULL,
  `lng` double DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `station_members`
--

CREATE TABLE `station_members` (
  `user_id` int NOT NULL,
  `station_id` int NOT NULL,
  `role` enum('viewer','admin') NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `users`
--

CREATE TABLE `users` (
  `id` int NOT NULL,
  `username` varchar(50) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password_hash` varchar(100) NOT NULL,
  `role` enum('member','super_admin') NOT NULL DEFAULT 'member',
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Indexes for dumped tables
--

--
-- Indeks untuk tabel `audit_log`
--
ALTER TABLE `audit_log`
  ADD PRIMARY KEY (`id`);

--
-- Indeks untuk tabel `jadwal_pompa`
--
ALTER TABLE `jadwal_pompa`
  ADD PRIMARY KEY (`stasiun_id`,`pompa`),
  ADD UNIQUE KEY `unique_pompa_per_stasiun` (`pompa`,`stasiun_id`);

--
-- Indeks untuk tabel `readings`
--
ALTER TABLE `readings`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_readings_stasiun_waktu` (`stasiun_id`,`timestamp`);

--
-- Indeks untuk tabel `readings_lama`
--
ALTER TABLE `readings_lama`
  ADD PRIMARY KEY (`id`);

--
-- Indeks untuk tabel `stations`
--
ALTER TABLE `stations`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `nama` (`nama`);

--
-- Indeks untuk tabel `station_members`
--
ALTER TABLE `station_members`
  ADD PRIMARY KEY (`user_id`,`station_id`);

--
-- Indeks untuk tabel `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `username` (`username`);

--
-- AUTO_INCREMENT untuk tabel yang dibuang
--

--
-- AUTO_INCREMENT untuk tabel `audit_log`
--
ALTER TABLE `audit_log`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `readings`
--
ALTER TABLE `readings`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `readings_lama`
--
ALTER TABLE `readings_lama`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `users`
--
ALTER TABLE `users`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- Ketidakleluasaan untuk tabel pelimpahan (Dumped Tables)
--

--
-- Ketidakleluasaan untuk tabel `station_members`
--
ALTER TABLE `station_members`
  ADD CONSTRAINT `station_members_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
