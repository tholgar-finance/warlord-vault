---
order: 2
---

# Withdraw

You can currently withdraw your tWAR into WAR tokens.

### Fee
A withdraw fee is taken to avoid front-running. Frontrunning occurs when a user deposit right before a compound and withdraw right after, profiting from the vault performance without participating to it. 
To counter this behavior, a 1.5% fee is taken from the withdraw amount. Note that this fee does not go to the protocol but is rather shared amongst all vault users.

### Accessing WAR withdraw

You can access the WAR withdraw by selecting the withdraw tab.

![](../assets/WarWithdraw.png)

### Withdrawing

#### Enter amount

Enter the desired amount of tWAR you wish to withdraw and click the "Withdraw" button.

#### withdraw

A dialog will open by first asking you to sign the withdraw transaction.

![](../assets/WarWithdraw-Withdraw.png)

#### Verify

The "Circulating Supply" and "War Locked" stats should be decreased by your withdraw amount. If it is not immediatly the case, try to refresh you page.

![](../assets/WarWithdraw-Withdrawn.png)