/* @flow */
import * as React from 'react'

import { CardView } from '../card-view'
import { UpcomingConventionCard } from '../conventions/upcoming-convention-card'
import { ConventionUserInfoCard } from './convention-user-info-card'
import type { Convention } from '../../model/convention'
import S from './index.css'

export type Props = {
  name: 'convention-details',
  convention: Convention,
}

export function ConventionDetails({ convention }: Props) {
  return (
    <CardView>
      <UpcomingConventionCard includeHours convention={convention} />
      <ConventionUserInfoCard hasSeeAllButton convention={convention} limit={5} />
    </CardView>
  )
}