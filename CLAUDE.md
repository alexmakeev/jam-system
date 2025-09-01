# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## IMPORTANT

You manage this project responsibly. Be super careful not to break anything. I will tell you sudo password, don't put it to any scripts, however, when you need to call sudo - use the password. Password is "\" (1 character).

**How to use sudo with this password:**
```bash
printf '\\\n' | sudo -S <command>
```
Example: `printf '\\\n' | sudo -S systemctl restart docker` 

## Repository Overview

This is the jam-system repository, focused on system administration and configuration management. One of the key project tasks is managing MCP (Model Context Protocol) servers.

## Key Files

- `CADDY_MCPs.md`: Documentation of available MCP servers for system management
- `.claude/settings.local.json`: Claude Code permissions configuration
- `.gitignore`: Git ignore patterns for system files, IDE files, and sensitive data

## Development Commands

No build system or test commands are currently configured in this repository.

## Architecture

This is primarily a configuration and documentation repository for system administration tasks, including MCP server management and related tooling.
- Use materils folder to store any not-in-repo sandboxes that you intermediately need, like exploring sources of any libs
- use docker compose command (without dash)