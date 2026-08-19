# MotionEye Home Assistant Add-on

A Home Assistant Community Add-on for motionEye - a web interface for the motion daemon.

## About

motionEye is a simple, elegant and feature-rich CCTV/NVR for your cameras. This add-on integrates motionEye with Home Assistant, allowing you to:

- Monitor multiple cameras
- View live streams
- Record video clips
- Configure motion detection
- Access via Home Assistant Ingress (no external port needed)

## Installation

1. Add this repository to your Home Assistant:
   - Go to **Settings** → **Add-ons** → **Repositories**
   - Click **Add Repository**
   - Enter the URL of this repository

2. Install the motionEye add-on:
   - Go to **Settings** → **Add-ons** → **Add-on Store**
   - Find **motionEye** and click **Install**

3. Configure your cameras in the motionEye web interface.

## Configuration

The add-on supports the following options:

| Option | Description |
|--------|-------------|
| `log_level` | Log level (trace, debug, info, notice, warning, error, fatal) |
| `motion_webcontrol` | Enable motion webcontrol (not recommended) |
| `ssl` | Use SSL for direct access |
| `certfile` | Certificate file for SSL |
| `keyfile` | Private key file for SSL |
| `action_buttons` | Configure action buttons for cameras |

## Access

- **Via Ingress**: Recommended. Access via Home Assistant's Ingress interface (no external port needed).
- **Via Direct Access**: If you expose port 80, you can access directly via `http://<ha-ip>:80`.

## Storage

The add-on maps the following directories:

| Path | Purpose |
|------|---------|
| `/share/motioneye` | Media files (videos, images) |
| `/media` | SMB mount points |
| `/ssl` | SSL certificates (if using direct access with SSL) |

## Known Issues

- motionEye requires `host_network: true` for camera access. This is a limitation of the motion daemon.
- Some cameras may require additional configuration in the motionEye interface.

## Support

For support, please visit the [Home Assistant Community](https://community.home-assistant.io/).

## License

MIT License - see LICENSE file for details.
