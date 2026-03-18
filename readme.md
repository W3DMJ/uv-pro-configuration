# UV‑Pro AX.25 Configuration

## 📁 Configure `/etc/ax25/axports`

Before using the UV‑Pro Bluetooth TNC, edit the AX.25 ports file:

```
/etc/ax25/axports
```

Replace **NOCALL** with your actual callsign.

### **File Format**

```
name   callsign   speed   paclen   window   description
```

### **Example**

```
1   WL2K        115200   255   2   UVPRO Bluetooth TNC
2   NOCALL-2    115200   255   2   Peer-to-peer IP link
3   NOCALL-3    115200   255   2   Peer-to-peer IP link
```

Update `NOCALL-2` and `NOCALL-3` to match your callsign and SSID scheme.

---

## 🔌 Connecting and Disconnecting the UV‑Pro

Your `uv-monitor.sh` script supports explicit connect and disconnect commands.

### **Connect the UV‑Pro**

Use the AXPORT number from `/etc/ax25/axports`:

```
sudo uv-monitor.sh connect [AXPORT]
```

Example:

```
sudo uv-monitor.sh connect 1
```

### **Disconnect the UV‑Pro**

```
sudo uv-monitor.sh disconnect
```

