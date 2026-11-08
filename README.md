# Titanic Disaster – Survival Prediction (Python & R in Docker)

This repository predicts which passengers survived the Titanic disaster (April 15, 1912) using **logistic regression**. The same pipeline is implemented twice, each in its own Docker container:

- **Python** (`src/python/`): pandas + scikit-learn
- **R** (`src/r/`): base R `glm()`

Each script loads the data, cleans it and adds features, trains a logistic regression model, reports accuracy on the training set, and predicts on the test set. Every step prints to the terminal, so you only need to run the containers to see the full process.

> **The dataset is not included in this repo.** Step 2 below explains how to download it.

---

## Repository structure

```
titanic-disaster-hw3/
├── .gitignore
├── README.md
└── src/
    ├── data/                # <-- YOU put the Kaggle CSVs here (gitignored)
    │   ├── train.csv
    │   ├── test.csv
    │   └── gender_submission.csv
    ├── python/
    │   ├── Dockerfile
    │   ├── requirements.txt
    │   └── titanic.py
    └── r/
        ├── Dockerfile
        ├── install_packages.R
        └── titanic.R
```

---

## Prerequisites

You do **not** need Python or R installed locally. Docker handles everything.

Make sure Docker Desktop is **open and running** before Step 3. You can check with:

```bash
docker --version
docker info
```

---

## Step 1 – Clone the repository

```bash
git clone https://github.com/ajcoop03/titanic-disaster-hw3.git
cd titanic-disaster-hw3
```

**All commands below are run from this top-level `titanic-disaster-hw3/` folder.**

---

## Step 2 – Download the data

The data comes from the Kaggle competition [Titanic – Machine Learning from Disaster](https://www.kaggle.com/competitions/titanic/data). You need three files: `train.csv`, `test.csv` and `gender_submission.csv`.

### Option A – Kaggle website (easiest)

1. Sign in to Kaggle and open https://www.kaggle.com/competitions/titanic/data
2. Click **Join Competition** / accept the rules (required before downloading).
3. Click **Download All**. This downloads `titanic.zip`.
4. Unzip it and move the three CSVs into `src/data/`:

```bash
mkdir -p src/data
unzip ~/Downloads/titanic.zip -d src/data
```

### Option B – Kaggle CLI

```bash
pip install kaggle
# Put your API token (Kaggle > Settings > API > Create New Token) at ~/.kaggle/kaggle.json
mkdir -p src/data
kaggle competitions download -c titanic -p src/data
unzip src/data/titanic.zip -d src/data && rm src/data/titanic.zip
```

### Check the files are in the right place

```bash
ls src/data
# gender_submission.csv  test.csv  train.csv
```

The scripts will fail if the files are not in `src/data/` with exactly these names.

---

## Step 3 – Run the Python container

**Build the image:**

```bash
docker build -t titanic-python src/python
```

**Run the container** (the `-v` flag mounts your local `src/data` folder into the container):

macOS / Linux:
```bash
docker run --rm -v "$(pwd)/src/data:/app/data" titanic-python
```

Windows (PowerShell):
```powershell
docker run --rm -v "${PWD}/src/data:/app/data" titanic-python
```

---

## Step 4 – Run the R container

**Build the image** (the first build takes a few minutes while R packages install):

```bash
docker build -t titanic-r src/r
```

**Run the container:**

macOS / Linux:
```bash
docker run --rm -v "$(pwd)/src/data:/app/data" titanic-r
```

Windows (PowerShell):
```powershell
docker run --rm -v "${PWD}/src/data:/app/data" titanic-r
```

---

## What you will see in the terminal

Both containers print each step as it happens:

1. **Load and explore**: size of `train.csv`, missing values per column, and survival rate by sex
2. **Clean and add features** (each change is printed):
   - Fill missing `Age` and `Fare` with the training-set median, and missing `Embarked` with `S` (the most common port)
   - Encode `Sex` as 0/1 and encode `Embarked` as dummy variables
   - Add `FamilySize = SibSp + Parch + 1`
3. **Train**: logistic regression on `Pclass`, `Sex`, `Age`, `Fare`, `FamilySize` and `Embarked`
4. **Training accuracy**
5. **Test predictions**: load `test.csv`, apply the same cleaning, and predict survival
6. **Test accuracy**

### Expected results

| | Python | R |
|---|---|---|
| Training accuracy | 0.8013 | 0.7991 |
| Predicted survivors in test set | 156 of 418 | 156 of 418 |
| Test accuracy (vs `gender_submission.csv`) | 0.9378 | 0.9378 |

The two training accuracies differ slightly because scikit-learn's `LogisticRegression` applies L2 regularization by default, while R's `glm()` does not.

### Note on test accuracy

Kaggle's `test.csv` has **no `Survived` column**, since the real labels are hidden for the competition. To produce a test accuracy number, the scripts compare predictions against `gender_submission.csv` (Kaggle's sample baseline, which predicts that all women survive and all men die). That number shows agreement with the baseline, not true accuracy. To get true accuracy, the predictions would need to be submitted to the [Kaggle competition](https://www.kaggle.com/competitions/titanic).

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| `Cannot connect to the Docker daemon` | Open Docker Desktop and wait until it reports it is running. |
| `FileNotFoundError` / `cannot open file 'data/train.csv'` | The CSVs are not in `src/data/`, or you ran `docker run` from a folder other than the repo root. Run `ls src/data` from the repo root. |
| `403 Forbidden` from the Kaggle CLI | You haven't accepted the competition rules. Click **Join Competition** on the Kaggle page first. |
| Volume mount path errors on Windows | Use PowerShell with `${PWD}`, or write out the full path, e.g. `-v "C:/Users/you/titanic-disaster-hw3/src/data:/app/data"`. |
| Apple Silicon (M1/M2/M3) build issues with the R image | Add `--platform linux/amd64` to both `docker build` and `docker run`. |

---

## Cleanup (optional)

```bash
docker rmi titanic-python titanic-r
```
