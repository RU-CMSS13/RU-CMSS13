import { useBackend } from '../backend';
import { Box, NoticeBox, Section, Stack, Tabs } from '../components';
import { Window } from '../layouts';

export const FactionTask = (props, context) => {
  const { act, data } = useBackend(context);
  const { tasks = [], points, req_points } = data;

  return (
    <Window width={650} height={700}>
      <Window.Content scrollable>
        <Section title="Points">
          <Box fontSize="16px">
            {points}/{req_points}
          </Box>
        </Section>

        <Section title="tasks">
          <Tabs fluid>
            {tasks.map((entry, index) => (
              <Stack.Item key={index}>
                <NoticeBox>{entry.status}</NoticeBox>
                name={entry.name}
                desk={entry.desc}
                color={entry.color}
                <NoticeBox>{entry.status_desc}</NoticeBox>
              </Stack.Item>
            ))}
          </Tabs>
        </Section>
      </Window.Content>
    </Window>
  );
};
