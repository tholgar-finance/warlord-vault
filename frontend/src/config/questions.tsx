import { JSX } from 'react';
import { HStack, Link, Spacer, Text, VStack } from '@chakra-ui/react';

export const questions: { question: string; answer: string | (() => JSX.Element) }[] = [
  {
    question: 'What is Tholgar ?',
    answer:
      'Tholgar is an auto-compounder vault of WAR index from Paladin Finance. Its aim is to maximize your yield by auto compounding rewards from governance tokens'
  },
  {
    question: 'How to use Tholgar ?',
    answer:
      'When you deposit your tokens in Tholgar, you receive tWAR tokens, acting as a receipt and counting your shares in the auto-compounder. The value of each share increase every time the rewards are harvested. When you bring back your tWAR to withdraw, you receive your principal + your share ratio of the collected rewards.'
  },
  {
    question: 'What is the difference between tWAR and thWAR ?',
    answer:
      'thWAR is the second version of the vault meant to be more futureproof and gas efficient while tWAR is the first version of the vault. You can migrate your tWAR to thWAR at any time.'
  },
  {
    question: 'Which tokens can I use to deposit ? ',
    answer: 'You can currently deposit either with WAR token, AURA and CVX or ETH / WETH.'
  },
  {
    question: 'Which tokens can I withdraw ? ',
    answer:
      'You can exchange your tWAR to withdraw your principal and rewards in WAR. You will soon be able to withdraw in AURA and CVX. In the meantime you can use official warlord frontend to withdraw in AURA and CVX.'
  },
  {
    question: 'What are the fees',
    answer:
     () => (
      <VStack align={'flex-start'}>
        <Text>The only fees we take is 5% of total harvested amount. This fee is used to cover gas cost for the compound transactions.</Text>
        <Text>For thWAR, there is also a 1.5% withdrawal fee shared among all thWAR holders. This fees is used to prevent users not contributing to the yield.</Text>
      </VStack>
     )
  },
  {
    question: 'How often are rewards harvested ?',
    answer: 'Rewards are harvested once every two weeks'
  },
  {
    question: 'What about security? Can devs access my funds ?',
    answer: () => (
      <VStack align={'flex-start'}>
        <Text>
          Tholgar doesn&apos;t hold custody of your WAR, so if you keep it safe yourself, it&apos;s
          safe
        </Text>
        <Text>
          Tholgar has been built with careful attention to security and is based on the battle-tested
          auto-compounder vaults by Yearn, standardized by ERC-4626
        </Text>
      </VStack>
    )
  },
  {
    question: 'Where are contracts deployed at ?',
    answer: () => (
      <VStack align={'flex-start'}>
        <Text fontWeight={'bold'} fontSize={'large'}>tWAR:</Text>
        <HStack>
          <Text>Vault:</Text>
          <Link
            href="https://etherscan.io/address/0x188cA46Aa2c7ae10C14A931512B62991D5901453"
            isExternal>
            0x188cA46Aa2c7ae10C14A931512B62991D5901453
          </Link>
        </HStack>
        <HStack>
          <Text>Zap:</Text>
          <Link
            href="https://etherscan.io/address/0x0598c652eEB0F95137Af02f32022005139453744"
            isExternal>
            0x0598c652eEB0F95137Af02f32022005139453744
          </Link>
        </HStack>
        <HStack>
          <Text>Swapper:</Text>
          <Link
            href="https://etherscan.io/address/0x4247d145049B426d39f19F41555137D9cB154B99"
            isExternal>
            0x4247d145049B426d39f19F41555137D9cB154B99
          </Link>
        </HStack>
        <Spacer />
        <Text fontWeight={'bold'} fontSize={'large'}>thWAR:</Text>
        <HStack>
          <Text>Vault:</Text>
          <Link
            href="https://etherscan.io/address/0x2fc1E74BC8A6D15fE768c10C2EDe7D6d95ec27e9"
            isExternal>
            0x2fc1E74BC8A6D15fE768c10C2EDe7D6d95ec27e9
          </Link>
        </HStack>
        <HStack>
          <Text>Zapper:</Text>
          <Link
            href="https://etherscan.io/address/0x1Ec2b9a77A7226ACD457954820197F89B3E3a578"
            isExternal>
            0x1Ec2b9a77A7226ACD457954820197F89B3E3a578
          </Link>
        </HStack>
        <HStack>
          <Text>Swapper:</Text>
          <Link
            href="https://etherscan.io/address/0xF2B3038C8bB9c4B225841496CF1D4Ca47b4c90D6"
            isExternal>
            0xF2B3038C8bB9c4B225841496CF1D4Ca47b4c90D6
          </Link>
        </HStack>
        <HStack>
          <Text>Migration:</Text>
          <Link
            href="https://etherscan.io/address/0x18708A93aD916fCafA4Ba365cdC723FcD3d8c65C"
            isExternal>
            0x18708A93aD916fCafA4Ba365cdC723FcD3d8c65C
          </Link>
        </HStack>
      </VStack>
    )
  }
];
