import { classes } from 'common/react';
import { useState } from 'react';
import { useBackend } from 'tgui/backend';
import { Tabs } from 'tgui/components';
import { Table, TableCell, TableRow } from 'tgui/components/Table';
import { Window } from 'tgui/layouts';

interface PlaytimeRecord {
  total_time: number;
  ckey: string | undefined;
  job: string;
  playtime: number;
  bgcolor: string;
  textcolor: string;
  icondisplay: string | undefined;
}

interface PlaytimeData {
  stored_human_playtime: PlaytimeRecord[];
  total_human_playtime: number;
  stored_xeno_playtime: PlaytimeRecord[];
  total_xeno_playtime: number;
  stored_other_playtime: PlaytimeRecord[];
  total_other_playtime: number;
}

interface PlaytimeRows {
  playtime: PlaytimeData;
  best_playtime: PlaytimeRecord[];
}

export const Playtime = () => {
  const { data } = useBackend<PlaytimeRows>();
  const { playtime, best_playtime } = data;
  const [selected, setSelected] = useState('human');
  const [selectedGP, setSelectedGP] = useState('private');
  return (
    <Window theme={selected !== 'xeno' ? 'usmc' : 'hive_status'}>
      <Window.Content className="PlaytimeInterface" scrollable>
        <Tabs fluid>
          <Tabs.Tab
            selected={selectedGP === 'global'}
            onClick={() => setSelectedGP('global')}
          >
            Global
          </Tabs.Tab>
          <Tabs.Tab
            selected={selectedGP === 'private'}
            onClick={() => setSelectedGP('private')}
          >
            Private
          </Tabs.Tab>
        </Tabs>
        {selectedGP === 'global' ? (
          <Table>
            <PlaytimeTable playtime={best_playtime} total={0} />
          </Table>
        ) : (
          <Table>
            <Tabs fluid>
              <Tabs.Tab
                selected={selected === 'human'}
                onClick={() => setSelected('human')}
              >
                Human ({playtime.total_human_playtime} hr)
              </Tabs.Tab>
              <Tabs.Tab
                selected={selected === 'xeno'}
                onClick={() => setSelected('xeno')}
              >
                Xeno ({playtime.total_xeno_playtime} hr)
              </Tabs.Tab>
              <Tabs.Tab
                selected={selected === 'other'}
                onClick={() => setSelected('other')}
              >
                Other ({playtime.total_other_playtime} hr)
              </Tabs.Tab>
            </Tabs>
            {selected === 'human' && (
              <PlaytimeTable
                playtime={playtime.stored_human_playtime}
                total={playtime.total_human_playtime}
              />
            )}
            {selected === 'xeno' && (
              <PlaytimeTable
                playtime={playtime.stored_xeno_playtime}
                total={playtime.total_xeno_playtime}
              />
            )}
            {selected === 'other' && (
              <PlaytimeTable
                playtime={playtime.stored_other_playtime}
                total={playtime.total_other_playtime}
              />
            )}
          </Table>
        )}
      </Window.Content>
    </Window>
  );
};

const PlaytimeTable = (props: {
  readonly playtime: PlaytimeRecord[];
  readonly total: number;
}) => {
  return (
    <Table>
      {props.playtime.map((selected) => (
        <PlaytimeRow
          key={selected.job}
          data={selected}
          total={props.total || selected.total_time}
        />
      ))}
    </Table>
  );
};

const ProgressColor = (percent: number) => {
  if (percent < 25) {
    return 'linear-gradient(90deg, #ff5e5e 0%, #ff9a5e 100%)';
  }
  if (percent < 50) {
    return 'linear-gradient(90deg, #ff9a5e 0%, #ffcc5e 100%)';
  }
  if (percent < 75) {
    return 'linear-gradient(90deg, #ffcc5e 0%, #a2ff5e 100%)';
  }
  return 'linear-gradient(90deg, #a2ff5e 0%, #5eff86 100%)';
};

const PlaytimeRow = (props: {
  readonly data: PlaytimeRecord;
  readonly total: number;
}) => {
  const time_to_use = props.data.total_time || props.total;
  const percentage = (props.data.playtime / time_to_use) * 100;
  return (
    <>
      <TableRow className="PlaytimeRow">
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
        <TableCell>
          <span className="PercentSpan">{percentage.toFixed(1)}%</span>
        </TableCell>
      </TableRow>
      <TableRow
        className="PlaytimePercentRow"
        mt={0.5}
        style={{
          height: '4px',
          position: 'relative',
          backgroundColor: 'rgba(0, 0, 0, 0.2)',
          borderRadius: '2px',
          overflow: 'hidden',
        }}
      >
        <TableCell
          style={{
            position: 'absolute',
            left: '0',
            top: '0',
            height: '100%',
            width: `${percentage}%`,
            background: ProgressColor(percentage),
            borderRadius: '2px',
          }}
        />
      </TableRow>
    </>
  );
};
