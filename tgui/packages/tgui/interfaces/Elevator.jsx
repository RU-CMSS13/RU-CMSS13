import { useBackend } from '../backend';
import { Button } from '../components';
import { Window } from '../layouts';

export const Elevator = (props, context) => {
  const { act, data } = useBackend();
  const { buttons, current_floor } = data;

  return (
    <Window width={260} height={360}>
      <Window.Content>
        {current_floor} Floor
        {buttons.map((button) => (
          <Button
            key={button.id}
            disabled={button.disabled}
            color="transparent"
            width={'60px'}
            lineHeight={1.75}
            content={button.title || button.id}
            style={{
              borderColor: button.called ? 'green' : 'gray',
              borderStyle: 'solid',
              borderWidth: '1px',
              color: button.id === current_floor ? 'red' : '#2185d0',
            }}
            onClick={() => act('click', { id: button.id })}
          />
        ))}
      </Window.Content>
    </Window>
  );
};
