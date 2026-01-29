import { 
    Card, 
    CardBody,
    CardHeader,
    Heading,
} from '@chakra-ui/react'
import type { ComponentType } from 'react'

type Props = {
    name: string;
    component: ComponentType<any>;
}

export function CardWrapper({name, component: Component}: Props) {
    return (
    <Card 
        className='mb-8 flex w-full scroll-mt-20 flex-col shadow-md'
        w="700px"
        h="680px"
    >
        <CardHeader>
            <Heading size="md">{name}</Heading>
        </CardHeader>
        <CardBody>
            <Component/>
        </CardBody>
    </Card>
    );
}
