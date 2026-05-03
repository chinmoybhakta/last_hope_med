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
  <img src="assets\logo\medAILogo.jpg" alt="Qwen-MediCare-BD Logo" width="150"/>
</p>

> **স্বাস্থ্য আপনার হাতের মুঠোয়** *(Health in Your Hands)*

**Qwen-MediCare-BD** is a **fully offline, privacy-first** medical AI assistant designed specifically for Bangladesh. It can understand questions in both **English** and **Bangla**, provide detailed medical information, drug details, and health guidance — all without needing an internet connection after the initial one-time model download (~1.9 GB).

Built by fine-tuning **Qwen2.5-3B-Instruct** on 30,523 medical question-answer pairs including Bangladesh-specific disease and drug data, and optimized to a compact **1.8 GB Q4_K_M GGUF** format for mobile deployment.

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

## 🏗 Architecture
┌──────────────────────────────────────────────────────────────┐
│ FLUTTER MOBILE APP │
├──────────────────────────────────────────────────────────────┤
│ Splash → Onboarding → Home → Chat │
│ (Model Check) (Download) (Conversations) (Q&A) │
├──────────────────────────────────────────────────────────────┤
│ CORE SERVICES │
├──────────────────────────────────────────────────────────────┤
│ LlamaService TranslationService HiveService │
│ (LLM Inference) (Google ML Kit) (Chat Storage) │
├──────────────────────────────────────────────────────────────┤
│ FLUTTER FRAMEWORK │
│ Riverpod (State) llama_flutter_android google_mlkit │
├──────────────────────────────────────────────────────────────┤
│ ANDROID NATIVE │
│ llama.cpp (GGUF) ML Kit Translate Hive DB │
└──────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────┐
│ TRAINING PIPELINE │
├──────────────────────────────────────────────────────────────┤
│ Dataset → Preprocessing → QLoRA Fine-tuning → Merge → GGUF │
│ (JSONL) (ChatML) (Unsloth/Qwen) (FP16) (Q4_K_M)│
└──────────────────────────────────────────────────────────────┘


### Tech Stack

| Layer | Technology |
|-------|------------|
| **Mobile Framework** | Flutter 3.38+ |
| **State Management** | Riverpod |
| **Local DB** | Hive |
| **LLM Engine** | llama.cpp (via llama_flutter_android) |
| **Translation** | Google ML Kit (On-Device) |
| **Base Model** | Qwen2.5-3B-Instruct |
| **Fine-Tuning** | Unsloth + QLoRA (4-bit) |
| **GPU (Training)** | NVIDIA RTX 5080 Laptop (16GB VRAM) |
| **Quantization** | GGUF Q4_K_M |

---

## 🧠 Model Details

| Property | Value |
|----------|-------|
| **Base Model** | Qwen2.5-3B-Instruct |
| **Fine-Tuning Method** | QLoRA (4-bit) with Unsloth |
| **Training Examples** | 30,523 |
| **Epochs** | 3 |
| **Learning Rate** | 2e-4 |
| **LoRA Rank** | 16 |
| **Quantization** | Q4_K_M (GGUF) |
| **Model Size (GGUF)** | 1.8 GB |
| **Context Length** | 2048 tokens |
| **Languages** | English (primary), Bangla (via translation) |
