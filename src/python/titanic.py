import pandas as pd
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import accuracy_score

FEATURES = ["Pclass", "Sex", "Age", "Fare", "FamilySize", "Embarked_Q", "Embarked_S"]

# Load and explore
train = pd.read_csv("data/train.csv")
print(f"Loaded train.csv: {train.shape[0]} rows, {train.shape[1]} columns")
print("Missing values:\n", train.isnull().sum()[train.isnull().sum() > 0])
print("Survival rate by sex:\n", train.groupby("Sex")["Survived"].mean().round(3))


def prepare(df):
    df = df.copy()
    df["Age"] = df["Age"].fillna(train["Age"].median())
    df["Embarked"] = df["Embarked"].fillna("S")
    df["Fare"] = df["Fare"].fillna(train["Fare"].median())
    df["Sex"] = df["Sex"].map({"male": 0, "female": 1})
    df["Embarked_Q"] = (df["Embarked"] == "Q").astype(int)
    df["Embarked_S"] = (df["Embarked"] == "S").astype(int)
    df["FamilySize"] = df["SibSp"] + df["Parch"] + 1
    return df


# Clean and add features
train = prepare(train)
print("\nFilled missing Age/Fare with training median and Embarked with 'S'")
print("Encoded Sex as 0/1, one-hot encoded Embarked, added FamilySize")
print(f"Features used: {FEATURES}")

# Train and evaluate
model = LogisticRegression(max_iter=1000).fit(train[FEATURES], train["Survived"])
print(f"\nTraining accuracy: {accuracy_score(train['Survived'], model.predict(train[FEATURES])):.4f}")

# Predict on test set
test = prepare(pd.read_csv("data/test.csv"))
test["Survived"] = model.predict(test[FEATURES])
print(f"Loaded test.csv and predicted {test['Survived'].sum()} survivors of {len(test)}")

# test.csv has no labels, so compare against Kaggle's gender_submission.csv
truth = pd.read_csv("data/gender_submission.csv")
merged = test.merge(truth, on="PassengerId", suffixes=("_pred", "_true"))
print(f"Test accuracy (vs gender_submission.csv): {accuracy_score(merged['Survived_true'], merged['Survived_pred']):.4f}")
