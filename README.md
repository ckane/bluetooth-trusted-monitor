# Bluetooth Trusted Devices Monitor

This is a very simple script that uses `bluetoothctl` from [BlueZ](https://github.com/bluez/bluez) to handle
monitoring for disconnected trusted bluetooth devices, and automatically tries reconnecting them if they
become disconnected.

The purpose of this is an attempt to have an easy method for connecting simple bluetooth input or output
devices to a headless embedded Linux (like a Pi) and have it appear to "just work" when powering on the
pre-trusted bluetooth device(s). There are definitely security implications, as well as usability implications
where you want to use the device for other purposes too, so keep both of these in mind when using it.

As `root`, do the following:

Install the `bluetooth-trusted-monitor.sh`
```bash
mkdir -p /opt/bluetooth-trusted-monitor
cp bluetooth-trusted-monitor.sh /opt/bluetooth-trusted-monitor/
chmod 755 /opt/bluetooth-trusted-monitor/bluetooth-trusted-monitor.sh
```

Then, install `bluetooth-trusted-monitor.service`
```bash
cp bluetooth-trusted-monitor.service /etc/systemd/system/
systemctl daemon-reload
systemctl enable --now bluetooth-trusted-monitor.service
```

# Trusting a New Bluetooth Device

To add a new bluetooth device to the trust list, as root:
```bash
bluetoothctl trust 12:34:56:78:90:AB
```

If you don't know the Bluetooth device id, you can run `bluetoothctl scan on` to start actively monitoring
for bluetooth devices announcing themselves, and then put your device into discoverable / pairing mode, and
you should see it show up on the list.

Once you've added the device to your trust list, it should be connectable, you will need to turn it on and
then establish a connection to it in order to save the trust relationship:
```bash
bluetoothctl connect 12:34:56:78:90:AB
```

The following, or similar, should be displayed if it worked, and the LED indicator on the device (if any)
should indicate it is connected:
```
Attempting to connect to 12:34:56:78:90:AB
[CHG] Device 12:34:56:78:90:AB Connected: yes
[CHG] Device 12:34:56:78:90:AB Modalias: usb:v057Ep0330d0001
[CHG] Device 12:34:56:78:90:AB UUIDs: 00001124-0000-1000-8000-00805f9b34fb
[CHG] Device 12:34:56:78:90:AB UUIDs: 00001200-0000-1000-8000-00805f9b34fb
[CHG] Device 12:34:56:78:90:AB ServicesResolved: yes
[CHG] Device 12:34:56:78:90:AB WakeAllowed: yes
Connection successful
```

The important detail here is that you need to make sure you establish a connection soon after you trusted
the device, or else it will get un-cached by BlueZ and your trust setting will be forgotten.

# Testing

If it worked properly, the bluetooth device should remain connected (active indicator) for as long as either
the device or the BlueZ system is powered on. Furthermore, you should be able to turn the bluetooth device off
for extended periods of time (hours, days, etc...), and then it should be able to reconnect after turning on.
Similarly, you should be able to reboot the system running BlueZ, and then once it comes back up, you should
be able to reconnect the bluetooth device simply by powering it on.

# Un-trusting a New Bluetooth Device

To remove the device from the trust list, you'll need to run the following, as root:
```bash
bluetoothctl untrust 12:34:56:78:90:AB
bluetoothctl disconnect 12:34:56:78:90:AB
```

The above will disable the trust relationship, and then disconnect from the device (if connected). This will
free up the device for association with some other controller in your location.
