import { uniq } from 'common/collections';
import { decodeHtmlEntities } from 'common/string';
import { useBackend } from 'tgui/backend';
import { Section, Table } from 'tgui/components';
import { Window } from 'tgui/layouts';

import { classes } from '../../common/react';
import { departmentData } from './common/departments';

type CrewMember = {
  name: string;
  rank: string;
  departments: string[];
  status: string;
};

type Data = {
  manifest: CrewMember[];
};

export const CrewManifest = (props) => {
  const { act, data } = useBackend<Data>();

  let { manifest } = data;

  if (!manifest || manifest.length === 0) {
    return (
      <Window width={450} height={600}>
        <Window.Content>
          <Section title="No Crew Found">
            There doesn&apos;t seem to be anyone here.
          </Section>
        </Window.Content>
      </Window>
    );
  }

  const departments = uniq(manifest.flatMap((crew) => crew.departments)).sort(
    (a, b) =>
      Object.keys(departmentData).indexOf(a) -
      Object.keys(departmentData).indexOf(b),
  );

  const unassociated = manifest.filter((crew) => crew.departments.length === 0);

  return (
    <Window width={450} height={600}>
      <Window.Content scrollable>
        {departments.map((dept) => {
          let filtered_crew = manifest.filter(
            (crew) => crew.departments.indexOf(dept) !== -1,
          );

          return (
            <Section
              className={'CrewManifest--' + dept}
              title={departmentData[dept].name}
              key={dept}
            >
              <Table>
                {filtered_crew.map((crew) => (
                  <Table.Row key={crew.name + crew.rank}>
                    <Table.Cell
                      className="CrewManifest__Cell"
                      maxWidth="135px"
                      overflow="hidden"
                      width="40%"
                    >
                      {decodeHtmlEntities(crew.name)}
                    </Table.Cell>
                    <Table.Cell
                      className={classes([
                        'CrewManifest__Cell',
                        'CrewManifest__Cell--Rank',
                      ])}
                      maxWidth="135px"
                      overflow="hidden"
                      width="40%"
                    >
                      {decodeHtmlEntities(crew.rank)}
                    </Table.Cell>
                    <Table.Cell
                      className="CrewManifest__Cell"
                      maxWidth="40px"
                      overflow="hidden"
                      width="20%"
                    >
                      {crew.status || 'Unknown'}
                    </Table.Cell>
                  </Table.Row>
                ))}
              </Table>
            </Section>
          );
        })}
        {unassociated.length !== 0 && (
          <Section className={'CrewManifest--misc'} title="Misc">
            <Table>
              {unassociated.map((crew) => (
                <Table.Row key={crew.name + crew.rank}>
                  <Table.Cell
                    className="CrewManifest__Cell"
                    maxWidth="135px"
                    overflow="hidden"
                    width="40%"
                  >
                    {decodeHtmlEntities(crew.name)}
                  </Table.Cell>
                  <Table.Cell
                    className={classes([
                      'CrewManifest__Cell',
                      'CrewManifest__Cell--Rank',
                    ])}
                    maxWidth="135px"
                    overflow="hidden"
                    width="40%"
                  >
                    {decodeHtmlEntities(crew.rank)}
                  </Table.Cell>
                  <Table.Cell
                    className="CrewManifest__Cell"
                    maxWidth="40px"
                    overflow="hidden"
                    width="20%"
                  >
                    {crew.status || 'Unknown'}
                  </Table.Cell>
                </Table.Row>
              ))}
            </Table>
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};
