# LAST HOPE MED

## Bangladesh's First Fully Offline Medical AI Assistant

[![Flutter](https://img.shields.io/badge/Flutter-3.38.7-blue?logo=flutter)](https://flutter.dev)
[![Python](https://img.shields.io/badge/Python-3.13-blue?logo=python)](https://python.org)
[![PyTorch](https://img.shields.io/badge/PyTorch-2.10.0-red?logo=pytorch)](https://pytorch.org)
[![CUDA](https://img.shields.io/badge/CUDA-12.8-green?logo=nvidia)](https://developer.nvidia.com/cuda-toolkit)
[![HuggingFace](https://img.shields.io/badge/🤗-HuggingFace-yellow)](https://huggingface.co/CBrootA/Qwen-MediCare-BD)
[![License](https://img.shields.io/badge/License-MIT-lightgrey)](LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen)](CONTRIBUTING.md)

<p align="center">
  <img src="assets/icon.png" alt="Qwen-MediCare-BD Logo" width="150"/>
</p>

> **স্বাস্থ্য আপনার হাতের মুঠোয়** *(Health in Your Hands)*

**Qwen-MediCare-BD** is a **fully offline, privacy-first** medical AI assistant designed specifically for Bangladesh. It can understand questions in both **English** and **Bangla**, provide detailed medical information, drug details, and health guidance — all without needing an internet connection after the initial one-time model download (~1.9 GB).

Built by fine-tuning **Qwen2.5-3B-Instruct** on 30,523 medical question-answer pairs including Bangladesh-specific disease and drug data, and optimized to a compact **1.8 GB Q4_K_M GGUF** format for mobile deployment.

---

## 📑 Table of Contents

- [✨ Features](#-features)
- [📸 Screenshots](#-screenshots)
- [🏗 Architecture](#-architecture)
- [🧠 Model Details](#-model-details)
- [📱 Mobile App](#-mobile-app)
- [🚀 Getting Started](#-getting-started)
  - [Prerequisites](#prerequisites)
  - [Installation (Mobile App)](#installation-mobile-app)
  - [Training (Optional)](#training-optional)
- [📊 Dataset](#-dataset)
- [🔄 Pipeline Overview](#-pipeline-overview)
- [📁 Project Structure](#-project-structure)
- [🔒 Privacy & Security](#-privacy--security)
- [⚕️ Medical Disclaimer](#%EF%B8%8F-medical-disclaimer)
- [📜 License](#-license)
- [🙏 Acknowledgments](#-acknowledgments)
- [📞 Contact](#-contact)

---

## ✨ Features

| Feature | Description |
|---------|-------------|
| 🇧🇩 **Bangla Support** | Ask questions in Bangla or English, get answers in your preferred language |
| 📴 **100% Offline** | One-time download (~1.9 GB), then works entirely without internet |
| 🔒 **Privacy First** | No data collection, no tracking, no cloud. Everything stays on your device |
| 🩺 **Medical Knowledge** | Fine-tuned on 30K+ medical Q&A pairs covering diseases, symptoms, drugs, and treatments |
| 💊 **Drug Database** | Includes generic names, Bangladesh brand names, dosage info, and price ranges |
| ⚡ **Fast Inference** | 19-133 tokens/sec on mobile CPU with Q4_K_M quantization |
| 📱 **Lightweight** | Only 1.8 GB model size fits mid-range Android devices (4GB+ RAM) |
| 🌐 **Google ML Kit** | On-device translation for Bangla ↔ English conversion |
| 💾 **Local Storage** | Chat history stored locally using Hive, with delete/edit/copy support |
| 🎯 **Clean UI** | Minimal, intuitive Flutter interface with animated onboarding |

---

## 📸 Screenshots

<p align="center">
  <table>
    <tr>
      <td align="center"><b>Splash</b></td>
      <td align="center"><b>Onboarding</b></td>
      <td align="center"><b>Chat (English)</b></td>
      <td align="center"><b>Chat (Bangla)</b></td>
    </tr>
    <tr>
      <td><img src="screenshots/splash.png" width="180"/></td>
      <td><img src="screenshots/onboarding.png" width="180"/></td>
      <td><img src="screenshots/chat_en.png" width="180"/></td>
      <td><img src="screenshots/chat_bn.png" width="180"/></td>
    </tr>
  </table>
</p>

---

## 🏗 Architecture
