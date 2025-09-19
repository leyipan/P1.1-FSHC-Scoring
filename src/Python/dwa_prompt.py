#!/usr/bin/env python
# coding: utf-8

from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]

# Helpers
def raw_file(filename: str) -> Path:
    return ROOT / "data" / "raw" / filename

def proc_file(filename: str) -> Path:
    return ROOT / "data" / "processed" / filename

def out_file(filename: str) -> Path:
    return ROOT / "output" / filename


# In[ ]:


pip install openai


# In[2]:


import os
from openai import OpenAI
import csv
import time


# In[3]:


# Set API Key
client = OpenAI(
    api_key="")


# In[4]:


# Load prompts from txt file
with open(proc_file("FSHC_prompts_with_titles.txt"), "r", encoding="utf-8") as f:
    content = f.read()

# Split by delimiter
prompts = [p.strip() for p in content.split("===PROMPT_START===") if p.strip()]


# In[5]:


raw = client.responses.with_raw_response.create(
    model="gpt-4o-mini",
    input="hi",
)

# HTTP headers are here:
headers = raw.headers
print("RPM limit:", headers.get("x-ratelimit-limit-requests"))
print("TPM limit:", headers.get("x-ratelimit-limit-tokens"))
print("TPM remaining:", headers.get("x-ratelimit-remaining-tokens"))


# In[6]:


# Prepare output file
with open(proc_file("dwa_ratings.csv"), mode="w", newline="", encoding="utf-8") as csvfile:
    writer = csv.writer(csvfile)
    writer.writerow(["ratings"])  # Header

    # Loop through prompts and get completions
    for idx, prompt in enumerate(prompts):
        try:
            response = client.responses.create(
                model="gpt-4o-mini",
                input=prompt,
                temperature=0,
            )
            answer = response.output[0].content[0].text.strip()
        except Exception as e:
            answer = f"ERROR: {str(e)}"

        # Save to CSV
        writer.writerow([answer])

        # Print progress and sleep to avoid rate limits
        print(f"Processed prompt {idx + 1}/{len(prompts)}")
        time.sleep(1)



