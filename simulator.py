# importing useful libraries
import random
import csv

N = 1000  # Number of voters


# Function to calculate Elo rating
def elo(rating):
    return 1 / (1 + 10 ** ((1500 - rating) / 400))  # 1500 considered baseline rating


def main():
    # Input delta_p and delta_q which represent magnitude of variation of 'p' and 'q' respectively, to be tested
    delta_p = float(input("Enter the delta_p: "))
    delta_q = float(input("Enter the delta_q: "))
    print("Running Simulation...")

    # Create header for CSV file
    header = [""]
    p = 0
    while p <= 1:
        header.append("p = " + str(round(p, 2)))
        p += delta_p

    with open("results.csv", "w") as f:
        writer = csv.writer(f)
        writer.writerow(header)

    # Initialize q
    q = 0

    # Loop for varying q (percentage of malicious voters parameter)

    # Iterate over q and p values to simulate the voting process
    while q <= 1:
        h = 1 - q  # Honest ratio
        p = 0  # Initialize p
        current_errors = (
            []
        )  # keep track of errors for each p value corresponding to a q
        current_errors.append("q = " + str(round(q, 2)))

        # Loop for varying p (trustworthy out of honest voters parameter)
        while p <= 1:
            voter_ratings = [1500] * N  # Initialize voter ratings
            k = int(N / 10)  # Number of committee members

            # Assign higher ratings to some members according to result of initial examination
            for i in range(k):
                voter_ratings[i] = 6000

            err_count = 0  # Initialize error count

            # Simulate voting process for 1000 articles
            for i in range(1000):
                article = random.randint(
                    0, 1
                )  # Randomly select an article and it's truth value
                opinions = [0] * N  # Initialize opinions

                # Assign opinions to honest voters based on their trustworthiness
                for j in range(int(N * h * p)):
                    ran = random.uniform(0, 1)
                    if ran <= 0.9:
                        opinions[j] = article
                    else:
                        opinions[j] = 1 - article

                # Assign opinions to rest of the honest voters
                for j in range(int(N * h * p), int(N * h)):
                    ran = random.uniform(0, 1)
                    if ran <= 0.7:
                        opinions[j] = article
                    else:
                        opinions[j] = 1 - article

                # Assign opinions to malicious voters - They always vote opposite to the actual truth
                for j in range(int(N * h), N):
                    opinions[j] = 1 - article

                # Calculate weights of opinions
                weight0 = sum(voter_ratings[j] for j in range(N) if opinions[j] == 0)
                weight1 = sum(voter_ratings[j] for j in range(N) if opinions[j] == 1)

                # Determine the final public vote for the article based on weights
                if weight1 >= weight0:
                    ans = 1
                else:
                    ans = 0

                # Calculate committee weights
                committee_ratings = [
                    (voter_ratings[i], i) for i in range(len(voter_ratings))
                ]
                committee_ratings.sort(reverse=True)
                comm_weight0 = sum(
                    committee_ratings[j][0]
                    for j in range(k)
                    if opinions[committee_ratings[j][1]] == 0
                )
                comm_weight1 = sum(
                    committee_ratings[j][0]
                    for j in range(k)
                    if opinions[committee_ratings[j][1]] == 1
                )

                # Determine the voted article based on committee weights
                if comm_weight1 >= comm_weight0:
                    comm_ans = 1
                else:
                    comm_ans = 0

                # Update voter ratings based on correctness of vote
                for j in range(N):
                    if opinions[j] == comm_ans:
                        voter_ratings[j] += 30 * (1 - elo(voter_ratings[j]))
                    else:
                        voter_ratings[j] += 30 * (0 - elo(voter_ratings[j]))

                # Count errors
                if ans != article:
                    err_count += 1

            # Store error count for current p value
            current_errors.append(err_count)
            p += delta_p  # Increment p

        # Write error counts to CSV
        with open("results.csv", "a") as f:
            writer = csv.writer(f)
            writer.writerow(current_errors)
        # print(voter_ratings)
        q += delta_q  # Increment q

    print("Simulation Completed!")


if __name__ == "__main__":
    main()
