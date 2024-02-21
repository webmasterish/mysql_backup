# MySQL Backup Script

The MySQL Backup Script is a Bash script designed to simplify the process of backing up MySQL databases. It provides a flexible solution for both manual backups through the command line interface (CLI) and automated backups via cron jobs. The script allows users to specify configuration parameters such as the backup directory, MySQL credentials, and retention policy, making it easy to adapt to various backup requirements. With its ability to compress backups and remove old backups based on a specified time frame, the MySQL Backup Script offers a robust and efficient solution for MySQL database backups.


## Usage

This script can be used both from the command line interface (CLI) and as a cron job.

### CLI

To execute the script from the command line interface:

```bash

bash mysql_backup.sh

# or

./mysql_backup.sh

```

### Cron Job

To schedule the script as a cron job, add the following line to your crontab:

```bash

# open crontab
crontab -e

# add the following wich will execute the script daily at 2:00 AM
# adjust the timing according to your requirements.
0 2 * * * /path/to/mysql_backup.sh >/dev/null 2>&1

```

Make sure to replace `/path/to/mysql_backup.sh` with the actual path to the script file.

Before running the script, ensure that you have set up the required configuration in the `mysql_backup.config` file. If this file is not present in the same directory as the script, make sure to provide its path as an argument when executing the script:

```bash

bash mysql_backup.sh /path/to/mysql_backup.config

```

### Configuration

The script requires a configuration file named `mysql_backup.config` to be present in the same directory. You can also specify the path to a different configuration file as an argument when executing the script from the command line.

Refer to the `mysql_backup.config.example` file for the required configuration parameters.

```bash

# required
BACKUP_DIR="/path/to/mysql/backups"
MYSQL_USER="mysql_username"
MYSQL_PASS="mysql_password"
MYSQL_HOST="mysql_host"

# optional
SINGLE_BACKUP_FILE=
COMPRESS=
DAYS_TO_KEEP=7

```

Ensure that the configuration file is readable. If the file is unreadable or missing required parameters, the script will terminate with an error message.


## License

MIT © [webmasterish](https://webmasterish.com)

