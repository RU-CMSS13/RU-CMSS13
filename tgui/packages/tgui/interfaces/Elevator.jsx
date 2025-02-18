import { useBackend } from '../backend';
import { Button, NoticeBox } from '../components';
import { Window } from '../layouts';

export const Elevator = (props, context) => {
  const { act, data } = useBackend();
  const { buttons, current_floor } = data;

  return (
    <Window width={260} height={360}>
      <Window.Content>
        <NoticeBox info>{current_floor} Floor</NoticeBox>
        {buttons.map((button) => (
          <Button
            key={button.id}
            color="transparent"
            width={'60px'}
            lineHeight={1.75}
            content={button.title || button.id}
            style={{
              borderColor: button.called ? 'green' : 'gray',
              borderStyle: 'solid',
              borderWidth: '1px',
              color: button.id === current_floor ? '#9e8c39' : '#37bc97',
            }}
            onClick={() => act('click', { id: button.id })}
          />
        ))}
        <NoticeBox info>(C) W-Y General Elevator Systems</NoticeBox>
      </Window.Content>
    </Window>
  );
};
