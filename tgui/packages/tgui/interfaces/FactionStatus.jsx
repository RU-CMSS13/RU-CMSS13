import { useBackend } from '../backend';
import { Box, Button, Collapsible, Divider } from '../components';
import { Window } from '../layouts';

export const FactionStatus = (props, context) => {
  const { act, data } = useBackend(context);
  const { faction_name, faction_desc, faction_orders, faction_color, actions } =
    data;

  return (
    <Window title={faction_name + ' Status'} resizable width={800} height={800}>
      <Window.Content scrollable>
        <FactionCollapsible
          title="General Faction Information"
          faction_color={faction_color}
        >
          <Box direction="column">
            <Box>
              <h3 className="whiteTitle">{faction_desc}</h3>
            </Box>
            <Box align="center">
              <i>Orders: {faction_orders}</i>
            </Box>
          </Box>
        </FactionCollapsible>
        <Divider />
        <FactionCollapsible
          fill
          title="Faction Tabs"
          faction_color={faction_color}
        >
          {actions.map((x, index) => (
            <Button
              key={x.index}
              content={x.name}
              onClick={() => act(x.action)}
            />
          ))}
        </FactionCollapsible>
        <Divider />
      </Window.Content>
    </Window>
  );
};

const FactionCollapsible = (props, context) => {
  const { title, faction_color, children } = props;
  return (
    <Collapsible
      title={title}
      backgroundColor={!!faction_color && faction_color}
      color={!faction_color && 'white'}
      open
    >
      {children}
    </Collapsible>
  );
};
