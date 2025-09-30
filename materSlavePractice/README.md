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

---
 MySQL Replication and ProxySQL Test Plan

This document outlines the steps to verify MySQL replication with a deliberate lag and test read/write splitting using ProxySQL.

---
# MySQL Replication and ProxySQL Read/Write Splitting Lab

This document outlines a lab exercise to set up and verify asynchronous MySQL replication with a deliberate lag, and to demonstrate how ProxySQL handles read/write splitting while respecting that lag.

---
```bash
start all containers
cd masterSlavePractice
docker compose --file mysqlReplication.yml up -d --remove-orphans
```

## 1. Environment Setup
### A. Connect Databases (via DBeaver)

Connect to all four database instances using DBeaver with the specified credentials. This confirms connectivity to the entire cluster.

| Instance | Role | Port | Credentials |
| :--- | :--- | :--- | :--- |
| **Master** | Source | `3307` | *(Specified Credentials)* |
| **Replica 1** | Read Node | `3308` | *(Specified Credentials)* |
| **Replica 2** | Read Node | `3309` | *(Specified Credentials)* |
| **Replica 3** | Read Node | `3310` | *(Specified Credentials)* |

### B. Replication Status Check (Master and Replicas)

Run the following commands to confirm that replication is configured and running.

| Location | SQL Command | Expected Output |
| :--- | :--- | :--- |
| **Master (3307)** | `SHOW REPLICAS;` | Lists all connected replicas (3308, 3309, 3310). |
| **Replica (e.g., 3308)** | `SHOW REPLICA STATUS\G;` | Confirms replication threads are active (`Replica_IO_Running: Yes`, `Replica_SQL_Running: Yes`). Note the value of **`Seconds_Behind_Source`**. |

---

## 2. Test: Observe Replication Lag

This test establishes a baseline by observing the lag directly between the Master and a Replica.

### C. Create Table and Observe Lag

| Step | Location & SQL Command | Observation/Goal |
| :--- | :--- | :--- |
| **1. Write Operation (Master)** | **On Master (3307):**<br>```sql CREATE TABLE users (    id VARCHAR(36) PRIMARY KEY,    fname VARCHAR(226),    age INT);INSERT INTO users VALUES (UUID(), "akshay", 26);``` | Writes data to the Master and starts the replication process. |
| **2. Immediate Read (Replica)** | **On a Replica (e.g., 3308):**<br>```sql SELECT * FROM users;``` | **Observation:** The inserted row for **"akshay" will not be visible immediately**. <br> **Demonstrates:** The existence of **replication lag** in the asynchronous setup. |
| **3. Delayed Read (Replica)** | **Wait $\approx 10$ Seconds, then run again:**<br>```sqlSELECT * FROM users;``` | **Observation:** The row for **"akshay" should now be visible**. <br> **Confirmation:** Data eventually achieves **consistency** after the replication delay. |

---

## 3. Test: Replication Through ProxySQL

This test validates that ProxySQL successfully routes traffic and respects the known replication lag.

### A. Connect to ProxySQL (via DBeaver)

Connect to the ProxySQL client port, as this will act as the single endpoint for the application.

| Endpoint | Port | User | Password |
| :--- | :--- | :--- | :--- |
| `localhost` | `6033` | `root` | `root` |

### B. Verify Read/Write Splitting

**All commands below must be run through the ProxySQL connection (6033).**

| Step | SQL Command (via ProxySQL) | Observation & Conclusion |
| :--- | :--- | :--- |
| **1. Perform a Write** | ```sql INSERT INTO users VALUES (UUID(), "bharat", 30);``` | This query is routed to the **Master (3307)**. |
| **2. Immediate Read** | ```sqlSELECT * FROM users WHERE fname = 'bharat';``` | **Observation:** The row for **"bharat" will likely not be visible**. <br> **Conclusion:** The **INSERT** correctly went to the Master, but the **SELECT** was correctly routed to a **lagging Replica** (3308/3309/3310). |
| **3. Wait 10 Seconds and Re-Read** | ```sqlSELECT * FROM users WHERE fname = 'bharat';``` | **Observation:** The row for **"bharat" should now be visible**. <br> **Conclusion:** ProxySQL is successfully performing **read/write splitting**, and the system achieved **eventual consistency** after the replication delay. |

