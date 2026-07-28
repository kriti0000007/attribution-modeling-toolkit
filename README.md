# Attribution Modeling Toolkit

A reusable marketing attribution framework built in SQL and Python. Supports first-touch, last-touch, linear, and time-decay attribution models — with a built-in channel efficiency scoring system (CPC, CAC, ROI).

Originally built on Carvana e-commerce data. Designed to work with any company that has clicks, sales, and spend data.

---

## What it does

- Calculates CPC, CAC, and ROI across any channel taxonomy
- Supports 4 attribution models out of the box
- Flags unattributed conversions and explains why they occur
- Produces a budget reallocation recommendation based on ROI ranking
- Works with SQLite (local) or any SQL warehouse (Snowflake, BigQuery, Redshift)

---

## Who it is for

Any company with:
- A clicks or impressions table (user_id, channel, timestamp)
- A conversions or sales table (user_id, conversion timestamp, revenue)
- A spend table (channel, date, spend)

E-commerce, SaaS, marketplaces, subscription businesses.

---

## Quick Start

```bash
git clone https://github.com/kriti0000007/attribution-modeling-toolkit
cd attribution-modeling-toolkit
pip install -r requirements.txt
jupyter notebook
```

Open `dashboard/attribution_dashboard.ipynb` and point it at your data.

---

## Project Structure

```
attribution-modeling-toolkit/
├── README.md
├── requirements.txt
├── models/
│   ├── first_touch.sql          # 100% credit to first click
│   ├── last_touch.sql           # 100% credit to last click
│   ├── linear.sql               # Equal credit across all touches
│   └── time_decay.sql           # More credit to recent touches
├── queries/
│   ├── cpc_by_channel.sql       # Cost Per Click by channel category
│   ├── cac_by_partner.sql       # Customer Acquisition Cost by partner
│   ├── roi_by_channel.sql       # ROI by channel category
│   ├── channels_before_convert.sql  # Avg touchpoints before conversion
│   └── unattributed_sales.sql   # % conversions with no prior click
├── utils/
│   ├── parse_channels.py        # Parse channel name strings
│   ├── profit_calc.py           # Configurable profit formula
│   └── datetime_fix.py          # SQLite datetime normalization
├── dashboard/
│   └── attribution_dashboard.ipynb  # Full analysis notebook
└── data/
    └── sample/                  # Sample data to test the toolkit
        ├── clicks_sample.csv
        ├── sales_sample.csv
        └── spend_sample.csv
```

---

## Attribution Models Explained

| Model | Logic | Best for |
|---|---|---|
| First-touch | 100% credit to first click | Awareness channel measurement |
| Last-touch | 100% credit to last click | Direct response campaigns |
| Linear | Equal credit to all touches | Balanced multi-channel view |
| Time-decay | More credit to recent touches | Short consideration cycles |

---

## Key Findings from Original Analysis (Carvana)

The counterintuitive result: Finance Partnership had the highest CPC ($3.21) but the best ROI (2.31x). Why? Purchase-stage intent. Users clicking financing ads have already decided to buy — they are solving for how, not whether. That intent compresses the funnel dramatically.

Third Party Listing had the lowest ROI (0.28x) despite the highest spend ($62,500). Classic spend misalignment — platform attracts price-sensitive comparison shoppers who are hard to convert and easy to lose.

---

## License

MIT — use freely, attribution appreciated.
