
🧰 PowerShell Logger

PowerShell Logger is a lightweight, script-based PowerShell terminal that records every command and its output — including user session info — to a timestamped log file.
It’s designed for command auditing, session tracking, and reproducibility in administrative or cybersecurity workflows.

<p>----------------------------------------------------------------------------------------------------------------------------</p>

Usage:

 1. Normal logging mode (with optional custom file)
    ```
    powershell -ExecutionPolicy Bypass -File .\Logger.ps1
    powershell -ExecutionPolicy Bypass -File .\Logger.ps1 -File "C:\Logs\MyCustomLog.txt"
    ```

 3. Upload mode
    ```
    powershell -ExecutionPolicy Bypass -File .\Logger.ps1 -Upload -Url "http://10.10.101:8080" -File "C:\Logs\MyCustomLog.txt"
    ```

 File Upload Sample

 1. Windows
    ```
    powershell -ExecutionPolicy Bypass -File .\Logger.ps1 -Upload -Url "http://10.10.101:8080" -File "C:\Logs\MyCustomLog.txt"
    ```

 3. Operator Linux
    ```
    nc -lvnp 800 > MyCustomLog.txt
    ```

<p>----------------------------------------------------------------------------------------------------------------------------</p>

📁 Log File Example

File: <code>C:\Logs\Logger-20251006-112300.txt</code>
```
===== Logger session started =====
Session: {"session_id":"20251006-112300","started_at":"2025-10-06T11:23:00.415Z","user":"tom","hostname":"LAPTOP-01","platform":"en-US"}
====================================

[2025-10-06 11:23:15] Command: Get-Date
Output:
Monday, October 6, 2025 11:23:15 AM

[2025-10-06 11:23:30] Command: whoami
Output:
laptop-01\tom

===== Logger session ended at 2025-10-06T11:25:00.127Z =====
```
