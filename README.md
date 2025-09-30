# MySQL Replication with ProxySQL (Docker Compose)

## 📌 Overview
This project sets up **MySQL replication** with **ProxySQL** using Docker Compose.  
The goal is to achieve:
- ✅ **Replication** → One master and multiple replicas.
- ✅ **Read/Write Load Distribution** → Writes go to master, reads are balanced across replicas.
- ✅ **Scalability & High Availability** → Add more replicas to handle read-heavy workloads.

---

## 🗄️ Architecture

            ┌──────────────┐
            │   Application │
            └───────┬──────┘
                    │
                    ▼
            ┌────────────────┐
            │    ProxySQL    │
            └───────┬────────┘
            Writes  │  Reads
                    │
    ┌───────────────┴───────────────┐
    │                               │
    ┌────────────┐                  ┌────────────┐
    │  Master DB │  ◄────────────── │ Replica DB │
    └────────────┘   Replication    └────────────┘
    │
┌────────────┐
│ Replica DB │
└────────────┘


---

## 🎯 What You Achieve
- **Replication** ensures data durability and consistency across multiple MySQL nodes.  
- **ProxySQL** automatically splits:
  - 🔹 **Writes → Master**  
  - 🔹 **Reads → Replicas** (load-balanced).  
- **Horizontal scalability** → Add replicas to improve read throughput.  
- **High availability foundation** → Can integrate with tools like Orchestrator for auto failover.  

---

## 🚀 Usage
- Bring everything up:
  ```bash
  cd masterSlavePractice
  docker compose --file mysqlReplication.yml up -d --remove-orphans
  docker-compose up -d

---
