import { Fragment } from 'react';
import { Table, TableCell, TableRow } from 'tgui/components/Table';

import { useBackend } from '../backend';
import { Collapsible, NoticeBox, ProgressBar, Section } from '../components';
import { Window } from '../layouts';

interface HardpointValues {
  value_name: string;
  current_value: number;
  max_value: number;
}

interface HardpointInfo {
  name: string;
  integrity: number;
  hardpoint_data_additional: HardpointValues[];
}

interface ResistanceInfo {
  name: string;
  pct: number;
}

interface WalkerInfo {
  resistance_data: ResistanceInfo[];
  integrity: number;
  hardpoint_data: HardpointInfo[];
}

export const Walker = () => {
  const { data } = useBackend<WalkerInfo>();
  const { resistance_data, integrity, hardpoint_data } = data;

  const height = 150 + hardpoint_data.length * 80;

  return (
    <Window width={500} height={height}>
      <Window.Content>
        <Section>
          {integrity >= 0 ? (
            <ProgressBar
              value={integrity / 100}
              ranges={{
                good: [0.7, Infinity],
                average: [0.2, 0.7],
                bad: [-Infinity, 0.2],
              }}
            >
              Hull integrity: {integrity}%
            </ProgressBar>
          ) : (
            <NoticeBox danger>Hull destroyed!</NoticeBox>
          )}
        </Section>
        <Section>
          <Collapsible title="Current armour resistances">
            <ResistanceView resists={resistance_data} />
          </Collapsible>
        </Section>
        <Section title="Hardpoints">
          <HardpointTable hardpoints={hardpoint_data} />
        </Section>
      </Window.Content>
    </Window>
  );
};

const ResistanceView = (props: { readonly resists: ResistanceInfo[] }) => {
  return (
    <Table>
      {props.resists.map((resistance, index) => (
        <TableCell key={index}>
          <span className="GigaSpan">
            {resistance.name}: {resistance.pct * 100}%
          </span>
        </TableCell>
      ))}
    </Table>
  );
};

const HardpointTable = (props: { readonly hardpoints: HardpointInfo[] }) => {
  return (
    <>
      {props.hardpoints.map((hardpoint) => (
        <Table key={hardpoint.name}>
          <TableRow>
            <TableCell>
              <span className="LabelSpan">{hardpoint.name}</span>
            </TableCell>
          </TableRow>
          <TableRow>
            <TableCell>
              <ProgressBar
                value={hardpoint.integrity / 100}
                width={'100%'}
                ranges={{
                  good: [0.7, Infinity],
                  average: [0.2, 0.7],
                  bad: [-Infinity, 0.2],
                }}
              >
                Integrity: {hardpoint.integrity}%
              </ProgressBar>
            </TableCell>
          </TableRow>
          <TableRow>
            {hardpoint.hardpoint_data_additional.map((value) => (
              <ProgressBar
                key={value.value_name}
                width={100 / hardpoint.hardpoint_data_additional.length + '%'}
                value={value.current_value / value.max_value}
              >
                {value.value_name}: {value.current_value} / {value.max_value}
              </ProgressBar>
            ))}
          </TableRow>
        </Table>
      ))}
    </>
  );
};
