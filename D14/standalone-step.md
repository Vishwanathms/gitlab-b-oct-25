Here's your Grafana + AWS CloudWatch setup guide converted to **Markdown**:

---

# 📊 Grafana Installation & Integration with AWS CloudWatch

---

## ✅ Step 1: Install Grafana on a Linux Machine

### On Ubuntu / Debian:
```bash
sudo apt-get install -y software-properties-common
sudo add-apt-repository "deb https://packages.grafana.com/oss/deb stable main"
wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
sudo apt-get update
sudo apt-get install grafana -y
```

### Start & Enable Grafana:
```bash
sudo systemctl start grafana-server
sudo systemctl enable grafana-server
```

---

## ✅ Step 2: Allow Grafana Through Firewall (Optional)
```bash
sudo ufw allow 3000/tcp
```

---

## ✅ Step 3: Access Grafana Web UI

Open your browser and navigate to:  
**`http://<your-server-ip>:3000`**

**Default login:**
- **Username:** `admin`
- **Password:** `admin` (you’ll be prompted to change)

---

## ✅ Step 4: Create IAM Policy for CloudWatch Access

Create a policy in AWS with the following permissions:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "cloudwatch:ListMetrics",
        "cloudwatch:GetMetricData",
        "cloudwatch:GetMetricStatistics",
        "cloudwatch:DescribeAlarms",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams",
        "logs:GetLogEvents"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
```

Attach this policy to a new IAM **user** or **role**.

---

## ✅ Step 5: Create AWS Access Key

1. Go to IAM → Users → Your User → Security Credentials.
2. Create an access key.
3. Save the **Access Key ID** and **Secret Access Key**.

---

## ✅ Step 6: Add AWS CloudWatch Data Source in Grafana

1. Go to **Grafana UI → Settings → Data Sources → Add data source**.
2. Select **CloudWatch**.
3. Fill in the following:

   - **Auth Provider:** `Access & secret key`
   - **Access Key ID:** `YOUR_AWS_ACCESS_KEY_ID`
   - **Secret Access Key:** `YOUR_AWS_SECRET_ACCESS_KEY`
   - **Default Region:** `us-east-1` (or your region)

4. Click **Save & Test**.

---

## ✅ Step 7: Create Dashboards

1. Go to **Dashboards → New → Add Panel**.
2. Select **CloudWatch** as your data source.
3. Choose the desired namespace (`AWS/EC2`, `AWS/Lambda`, etc.).
4. Select metric, dimension, and visualization type.

---

## ✅ (Optional) Use EC2 IAM Role Instead of Access Key

If Grafana is running on an **EC2 instance**:

1. Attach an IAM role (with above policy) to the instance.
2. In Grafana → CloudWatch data source:
   - Choose **Auth Provider**: `EC2 IAM Role`

Grafana will auto-use the IAM role for authentication.

---

Let me know if you want this exported to a `.md` file or hosted in GitHub or S3.