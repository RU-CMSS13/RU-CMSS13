import { useBackend } from '../backend';
import { Button, NoticeBox, Stack } from '../components';
import { Window } from '../layouts';

export const SkyScraperSecurity = (props, context) => {
  const { act, data } = useBackend();
  const {
    current_scraper_link,
    security_floor,
    security_protocol,
    interaction_time_lock,
  } = data;

  return (
    <Window width={300} height={400}>
      <Window.Content>
        <NoticeBox info>
          {current_scraper_link} security terminal for {security_floor} Floor
        </NoticeBox>
        <NoticeBox danger>
          Security Protocol: {security_protocol ? 'On' : 'Off'}
        </NoticeBox>

        {security_protocol ? (
          <>
            <NoticeBox warning>
              Progress: {security_protocol.current_progress}%
            </NoticeBox>
            <Stack>
              {security_protocol.messages.map((message, index) => (
                <Stack.Item key={index}>
                  <NoticeBox success>{message}</NoticeBox>
                </Stack.Item>
              ))}
            </Stack>
            <Button
              disabled={security_protocol.running || interaction_time_lock}
              color="transparent"
              width={'200px'}
              lineHeight={1.75}
              content="System Link"
              style={{
                borderColor: '#37bc97',
                borderStyle: 'solid',
                borderWidth: '1px',
                color: '#9e8c39',
              }}
              onClick={() => act('security')}
            />
          </>
        ) : (
          <>
            <Button
              disabled={interaction_time_lock}
              color="transparent"
              width={'200px'}
              lineHeight={1.75}
              content="Lock Stairs"
              style={{
                borderColor: '#37bc97',
                borderStyle: 'solid',
                borderWidth: '1px',
                color: '#9e8c39',
              }}
              onClick={() => act('stairs')}
            />
            <Button
              disabled={interaction_time_lock}
              color="transparent"
              width={'200px'}
              lineHeight={1.75}
              content="Lock Elevator"
              style={{
                borderColor: '#37bc97',
                borderStyle: 'solid',
                borderWidth: '1px',
                color: '#9e8c39',
              }}
              onClick={() => act('elevator')}
            />
            <Button
              disabled={interaction_time_lock}
              color="transparent"
              width={'200px'}
              lineHeight={1.75}
              content="Unlock Floor"
              style={{
                borderColor: '#37bc97',
                borderStyle: 'solid',
                borderWidth: '1px',
                color: '#9e8c39',
              }}
              onClick={() => act('unlock')}
            />
          </>
        )}
        <NoticeBox info>(C) W-Y General Security Systems</NoticeBox>
      </Window.Content>
    </Window>
  );
};
