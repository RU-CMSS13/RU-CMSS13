import { classes } from 'common/react';
import { useState } from 'react';
import { useBackend } from 'tgui/backend';
import { Tabs } from 'tgui/components';
import { Table, TableCell, TableRow } from 'tgui/components/Table';
import { Window } from 'tgui/layouts';

interface PlaytimeRecord {
  ckey: string | undefined;
  job: string;
  playtime: number;
  bgcolor: string;
  textcolor: string;
  icondisplay: string | undefined;
}

interface PlaytimeData {
  stored_human_playtime: PlaytimeRecord[];
  stored_xeno_playtime: PlaytimeRecord[];
  stored_other_playtime: PlaytimeRecord[];
}

interface PlaytimeRows {
  playtime: PlaytimeData;
  best_playtime: PlaytimeRecord[];
}

const PlaytimeRow = (props: { readonly data: PlaytimeRecord }) => {
  return (
    <>
      <TableCell className="AwardCell">
        {props.data.icondisplay && (
          <span
            className={classes([
              'AwardIcon',
              'playtimerank32x32',
              props.data.icondisplay,
            ])}
          />
        )}
      </TableCell>
      <TableCell>
        <span className="LabelSpan">{props.data.job}</span>
      </TableCell>
      {props.data.ckey && (
        <TableCell>
          <span className="CkeySpan">{props.data.ckey}</span>
        </TableCell>
      )}
      <TableCell>
        <span className="TimeSpan">{props.data.playtime.toFixed(1)} hr</span>
      </TableCell>
    </>
  );
};

const PlaytimeTable = (props: { readonly data: PlaytimeRecord[] }) => {
  return (
    <Table>
      {props.data
        .slice(props.data.length > 1 ? 1 : 0)
        .filter((x) => x.playtime !== 0)
        .map((x) => (
          <TableRow key={x.job} className="PlaytimeRow">
            <PlaytimeRow data={x} />
          </TableRow>
        ))}
    </Table>
  );
};

export const Playtime = (props) => {
  const { data } = useBackend<PlaytimeRows>();
  const { playtime, best_playtime } = data;
  const [selected, setSelected] = useState('human');
  const humanTime =
    playtime.stored_human_playtime.length > 0
      ? playtime.stored_human_playtime[0].playtime
      : 0;
  const xenoTime =
    playtime.stored_xeno_playtime.length > 0
      ? playtime.stored_xeno_playtime[0].playtime
      : 0;
  const otherTime =
    playtime.stored_other_playtime.length > 0
      ? playtime.stored_other_playtime[0].playtime
      : 0;
  return (
    <Window theme={selected !== 'xeno' ? 'usmc' : 'hive_status'}>
      <Window.Content className="PlaytimeInterface" scrollable>
        <Tabs fluid>
          <Tabs.Tab
            selected={selected === 'global'}
            onClick={() => setSelected('global')}
          >
            Global
          </Tabs.Tab>
          <Tabs.Tab
            selected={selected === 'private'}
            onClick={() => setSelected('private')}
          >
            Private
          </Tabs.Tab>
        </Tabs>
        {selected === 'global' ? (
          <Table>
            <PlaytimeTable data={best_playtime} />
          </Table>
        ) : (
          <Table>
            <Tabs fluid>
              <Tabs.Tab
                selected={selected === 'human'}
                onClick={() => setSelected('human')}
              >
                Human ({humanTime} hr)
              </Tabs.Tab>
              <Tabs.Tab
                selected={selected === 'xeno'}
                onClick={() => setSelected('xeno')}
              >
                Xeno ({xenoTime} hr)
              </Tabs.Tab>
              <Tabs.Tab
                selected={selected === 'other'}
                onClick={() => setSelected('other')}
              >
                Other ({otherTime} hr)
              </Tabs.Tab>
            </Tabs>
            {selected === 'human' && (
              <PlaytimeTable data={playtime.stored_human_playtime} />
            )}
            {selected === 'xeno' && (
              <PlaytimeTable data={playtime.stored_xeno_playtime} />
            )}
            {selected === 'other' && (
              <PlaytimeTable data={playtime.stored_other_playtime} />
            )}
          </Table>
        )}
      </Window.Content>
    </Window>
  );
};
