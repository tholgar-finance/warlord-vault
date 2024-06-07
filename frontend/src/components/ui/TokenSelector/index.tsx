import { FC, useMemo, useState } from 'react';
import {
  Button,
  HStack,
  Image,
  Menu,
  MenuButton,
  MenuItem,
  MenuList,
  Text,
  useColorModeValue
} from '@chakra-ui/react';
import { ChevronDownIcon } from '@chakra-ui/icons';

export interface TokenSelectorProps {
  // eslint-disable-next-line no-unused-vars
  onTokenSelect: (token: string) => void;
  tokens: { id: string; name: string; iconUrl: string }[];
  selection?: string;
}

// eslint-disable-next-line no-unused-vars
const Item: FC<{ name: string; iconUrl: string }> = ({ name, iconUrl }) => (
  <HStack py={2}>
    <Image boxSize="2rem" borderRadius="full" src={iconUrl} alt={name} mr="12px" />
    <Text fontWeight={'medium'}>{name}</Text>
  </HStack>
);

export const TokenSelector: FC<TokenSelectorProps> = ({ onTokenSelect, tokens, selection }) => {
  const [idSelected, setIdSelected] = useState<string>(selection ?? tokens[0]?.id ?? '');
  const selected = useMemo(() => tokens.find((t) => t.id == idSelected), [idSelected, tokens]);
  const select = (token: string) => {
    setIdSelected(token);
    onTokenSelect(token);
  };

  return (
    <Menu matchWidth={true}>
      <MenuButton
        as={Button}
        opacity={1}
        backgroundColor={useColorModeValue('background.100.light', 'background.100.dark')}
        _hover={{}}
        _active={{}}
        rightIcon={<ChevronDownIcon />}
        w={'100%'}>
        <Item {...selected!} />
      </MenuButton>
      <MenuList w={'100%'}>
        {tokens.map((t) => (
          <MenuItem
            key={t.id}
            h={'3rem'}
            w={'full'}
            onClick={() => select(t.id)}
            _hover={{ color: 'brand.primary.400', transition: 'color 0.25s ease' }}>
            <Item {...t} />
          </MenuItem>
        ))}
      </MenuList>
    </Menu>
  );
};

TokenSelector.defaultProps = {};
