---
marp: true
theme: default
paginate: true
footer: 'SPC 2025 | Data Management Training | Vanuatu'
style: |
  section {
    background-color: #fff;
    font-size: 28px;
  }
  h1 {
    color: #2c5aa0;
  }
  h2 {
    color: #4a90e2;
  }
  .columns {
    display: grid;
    grid-template-columns: repeat(2, minmax(0, 1fr));
    gap: 1rem;
  }
---

<!-- _class: lead -->
<!-- _paginate: false -->

# Data Management with R

## Data Analysis Training for Vanuatu Fisheries

**Jessica Leiria Schattschneider and Benoit Pohl**
SPC 2025 - Data Management Training

---

# About Today's Training

- **Duration:** 2 days
- **Format:** Hands-on, practical
- **Goal:** Get you working with real data and have a sense of what can be done using R
- **No pressure:** We'll go step by step

**This is not about becoming an R expert!**  
It's about seeing how R can help you do your job.

---

# How This Training Works

<div class="columns">
<div>

### We'll Use

- **Quarto document** (step-by-step guide)
- **Discussion questions** (think together)
- **Live coding** (watch then try)
- **Exercises** (practice)

</div>
<div>

### You Should

- Follow along
- Ask questions anytime
- Try the exercises
- Don't worry about mistakes!

</div>
</div>

---

# What We'll Cover

1. Why use R for data management 
1. R Setup and basic commands
1. Exercise 1

    - How can I download the data from Tufman 2 reports?

1. Exercise 2

    - How can I analyse data from Tufman 2 reports?

1. Exercise 3

    - How can I reproduce the total catch and total catch values results presented in the [FFA report 2025](https://www.ffa.int/download/wcpfc-area-catch-value-estimates/)? 

---

# Why R is Good For Your Work

- **Traceable:** Always know what you did
- **Share methods:** Others can use your script
- **Reproducible:** Run the same analysis anytime (consistent)
- **Save time:** Minutes instead of hours
- **Free:** Open-source software
- **Efficient:** No more manual downloads
- **Find patterns:** Easier to explore data

---

# What is R?

- A **programming language** for data
- It is Free and Open Source
- Like Excel, but with code and with more potential
- Popular in research and science

**Think of it as:** A calculator that can remember and repeat your work

---

# What is RStudio?

- The **interface** for R
- Like Word is to writing, RStudio is to R
- Makes R easier to use
- Where we'll do all our work today

**Think of it as:** without RStudio you would need to run R in the Terminal.


---

# What is RCloud?

- Is an online version (cloud) of R and RStudio (like a Word Docs)
- Sign up to it and voila
- Requires no software installation
- Recommended for those who do not have R or RStudio installed yet

---

# .R and .qmd files

🧮 .R → Code only (scripts, data analysis, automation)

🧠 .qmd → Code and explanations (reports, tutorials, slides)

---

# Any Questions Before We Start?

### Common Questions:

- **"What if I get stuck?"** → We'll work through it together
- **"Do I need to be good at math?"** → No!
- **"Can I use this for other data?"** → Absolutely!
- **"What if it doesn't work?"** → That's part of learning!

---

# Let's start!

---

# What You Need

1. Tufman 2 access credentials  

1. Copy this training material using RStudio or Rcloud 
    - If you have R and RStudio installed: Go to: [config Rcloud](https://github.com/PacificCommunity/ofp-vu-2025-r-training/blob/main/config/Rcloud/README.md)
    - If you prefer to use RCloud: Go to: []


---

# Explore the materials available

---


# Key Concepts We'll Use

## Follow along: ./basics.qmd

### 1. Libraries and running individual lines

```r
library(DT)  # For interactive tables
```

---

# Key Concepts We'll Use

### 2. Assignment `<-`
Saving results to use later

```r
my_numbers <- c(5, 10, 15, 20, 25)
```

### 3. Functions

```r
mean(my_numbers)
max(my_numbers)
```

---

### 4. Dataframe and Pipes `|>`
Chains commands together (like "then do this")

```r
data |>
  head(2)
```

### 5. Filter and select `|>`
Chains commands together (like "then do this") and use filtering commands

```r
data |>
  filter(year == 2024) |>
  select(vessel, catch)
```

**Reads like:** "Take data, THEN filter by year, THEN select columns"

---

<div class="columns">
<div>

### Don't Worry About...

❌ Memorizing syntax
❌ Understanding every detail
❌ Writing code from scratch (yet)
❌ Being perfect

</div>
<div>

### Do Focus On...

✅ Following the workflow
✅ Understanding the logic
✅ Asking "why" and "what if"
✅ Seeing what's possible
✅ Google is your best friend!

---

# Most important things to remember:

<div class="columns">
<div>

![alt text](img/image-1.png)

</div>
<div>

---

# Most important things to remember:

<div class="columns">
<div>

![alt text](img/image-1.png)

</div>
<div>

![alt text](img/image.png)


<!-- <div class="columns">
<div>

### First Time
- Lots of new things
- Feels overwhelming
- Need to concentrate
- Make mistakes

</div>
<div>

### After Practice
- Becomes automatic
- Feels natural
- Can focus on destination
- Still learning new routes

</div>
</div> -->


---

# Resources for Later
**Save this slide for later!**

<div class="columns">
<div>

- **R for Data Science:** [r4ds.had.co.nz](https://r4ds.had.co.nz/)
- **RStudio Cheatsheets:** [posit.co/resources/cheatsheets](https://posit.co/resources/cheatsheets/)
- **R Community:** [community.rstudio.com](https://community.rstudio.com/)
- **RAW** https://spc.learnbook.com.au/course/view.php?id=95

</div>
<div>

<img src="img/image3.png" width="500" height="300" />


---

# What Happens After Today?

- A working script you can reuse (template)
- Understanding of the workflow
- Reach us out if you need support - jessicals@spc.int

