# VM-Autoconfig

A small Bash script to automate secure SSH setup for a Linux VM.

## Features

- Creates an `ssh-users` group for controlled SSH access
- Adds an existing admin user to `sudo` and `ssh-users`
- Creates the `.ssh` directory and `authorized_keys` with correct permissions
- Prompts for a public SSH key interactively
- Applies basic SSH hardening using `/etc/ssh/sshd_config.d/99-hardening.conf`
- Validates the SSH configuration before restarting the SSH service

## Included Files

- `setup-ssh.sh` – Configures SSH access and applies basic hardening
- `README.md` – Project documentation

## What the Script Changes

The script performs the following steps:

1. Creates the `ssh-users` group if it does not already exist
2. Checks whether the given admin user exists
3. Adds that user to:
   - `sudo`
   - `ssh-users`
4. Creates:
   - `/home/<user>/.ssh`
   - `/home/<user>/.ssh/authorized_keys`
5. Writes a provided public key into `authorized_keys`
6. Creates the SSH hardening file:
   - `/etc/ssh/sshd_config.d/99-hardening.conf`
7. Tests the SSH configuration with `sshd -t`
8. Restarts the SSH service

## SSH Hardening Applied

The script writes the following settings:

- `PermitRootLogin no`
- `PasswordAuthentication no`
- `KbdInteractiveAuthentication no`
- `PubkeyAuthentication yes`
- `AllowGroups ssh-users`
- `AuthorizedKeysFile .ssh/authorized_keys`

## Requirements

- A Linux system with OpenSSH server installed
- Root privileges
- An already existing user account that should become the admin SSH user
- `sudo`, `groupadd`, `usermod`, `sshd`, and `systemctl` available

## Usage

Run the script as root:

```bash
sudo bash setup-ssh.sh <admin-user>
```

Example:

```bash
sudo bash setup-ssh.sh andrej
```

If no username is provided, the script uses:

```bash
adminuser
```

During execution, you will be prompted to paste a public SSH key.

Example public key:

```text
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIExampleKeyHere user@host
```

## Important Notes

- The target user must already exist before running the script
- Password-based SSH login will be disabled
- Root login via SSH will be disabled
- Only members of the `ssh-users` group will be allowed to log in via SSH
- Make sure your public key works before disconnecting from the VM

## Recommended Workflow

1. Create your admin user
2. Verify the user can use `sudo`
3. Run this script as root
4. Paste your public key when prompted
5. Test a new SSH session before closing the current one

## Example

```bash
adduser andrej
usermod -aG sudo andrej
sudo bash setup-ssh.sh andrej
```

## Warning

Incorrect SSH configuration can lock you out of your VM.  
Always keep an existing session open while testing changes.

## License

No license specified yet.
