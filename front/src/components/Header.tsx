import { Flex, Heading, HStack } from "@chakra-ui/react";

export default function Header() {
  return (
    <>
      <Flex
        as="nav"
        bg="#ffffff"
        color="#000000"
        align="center"
        justify="space-between"
        padding={{ base: 3, md: 5 }}
        boxShadow="md"
        mb={6}
        h="60px"
        position="fixed"
        w="100%"  
        top="0"
        zIndex={900} 
      >
        <Flex align="center" as="a" mr={8}>
          <Heading as="h1" fontSize={{ base: "md", md: "lg" }}>
            <HStack>
              <img
                src="/workflow.svg"
                alt="パイプラインアイコン"
                className="mr-2 h-6 w-6"
              />
              <span className="font-bold text-lg">fpga image pipeline</span>
            </HStack>
          </Heading>
        </Flex>
      </Flex>
    </>
  );
}
